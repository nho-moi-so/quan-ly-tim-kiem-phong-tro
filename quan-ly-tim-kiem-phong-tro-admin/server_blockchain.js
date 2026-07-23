/*
 * FILE: server_blockchain.js
 * Chức năng: Gộp cả API Gateway và Clocker System
 * 1. REST API cho IoT gọi vào kiểm tra mật khẩu
 * 2. Hệ thống tự động quét và xử lý check-in/check-out
 * Cách chạy: node server_blockchain.js
 */
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

process.env.TS_NODE_PROJECT = path.resolve(__dirname, 'tsconfig.server.json');

import bodyParser from 'body-parser';
import cors from 'cors';
import crypto from 'crypto';
import express from 'express';
import { TextDecoder } from 'util';
import { createFabricClient } from './src/lib/fabric/fabricClient.ts';
import { ApartmentRepository } from './src/repositories/apartmentRepository.ts';
import { ContractRepository } from './src/repositories/contractRepository.ts';
import { UserRepository } from './src/repositories/userRepository.ts';

// --- CẤU HÌNH EXPRESS ---
const app = express();
const PORT = Number.parseInt(process.env.BLOCKCHAIN_PORT || '3001', 10);
app.use(cors());
app.use(bodyParser.json());

// --- HÀM TIỆN ÍCH CHUNG ---
const decoder = new TextDecoder();

function hashPassword(password) {
	return crypto.createHash('sha256').update(password).digest('hex');
}

function getCurrentTimestamp() {
	return Math.floor(Date.now() / 1000);
}
function randomPassword(length = 8) {
	const chars = '0123456789';
	let result = '';
	for (let i = 0; i < length; i++) {
		result += chars[Math.floor(Math.random() * chars.length)];
	}
	return result;
}

async function withFabricContract(handler) {
	const { contract, close } = await createFabricClient();
	try {
		return await handler(contract);
	} finally {
		close();
	}
}


// ========================================
// PHẦN 1: REST API CHO IOT
// ========================================

app.post('/api/verify', async (req, res) => {
	const { apartmentId, password } = req.body;

	console.log(`\n[API] Nhận yêu cầu từ IoT: ApartmentId=${apartmentId}, Pass=${password}`);

	// //từ roomCode lấy apartmentId
	// const apartmentId = await ApartmentRepository.getApartmentIdByRoomCode(roomCode);

	if (!apartmentId || !password) {
		return res.status(400).json({ error: 'Thiếu apartmentId hoặc password' });
	}

	const passwordHashToSend = hashPassword(password);
	console.log(`   [API] Đã băm mật khẩu thành: ${passwordHashToSend}`);

	try {
		const resultBytes = await withFabricContract((contract) =>
			contract.evaluateTransaction('VerifyAccess', apartmentId, passwordHashToSend)
		);
		const resultString = decoder.decode(resultBytes);

		if (resultString === 'true') {
			console.log('   [API] MẬT KHẨU ĐÚNG -> ACCESS GRANTED');
			return res.json({
				status: 'success',
				access: true,
				message: 'Mở cửa thành công',
			});
		}

		console.log('   [API] MẬT KHẨU SAI -> ACCESS DENIED');
		return res.json({
			status: 'success',
			access: false,
			message: 'Sai mật khẩu',
		});
	} catch (error) {
		console.error(`   [API] Lỗi kết nối Blockchain: ${error.message}`);
		return res.status(500).json({ error: error.message });
	}
});

app.post('/api/get-password', async (req, res) => {
	const { roomCode } = req.body;

	console.log(`\n[API] Nhận yêu cầu lấy mật khẩu: RoomCode=${roomCode}`);

	if (!roomCode) {
		return res.status(400).json({ error: 'Thiếu roomCode' });
	}
	const apartment = await ApartmentRepository.getByRoomCode(roomCode);
	const apartmentId = apartment?.Id;
	if (!apartmentId) {
		return res.status(404).json({ error: 'Không tìm thấy căn hộ với roomCode đã cho' });
	}
	try {
		const resultBytes = await withFabricContract((contract) =>
			contract.evaluateTransaction('GetPasswordHashByApartmentId', apartmentId)
		);
		const passwordHash = decoder.decode(resultBytes);

		return res.json({
			status: 'success',
			apartmentId,
			passwordHash,
		});
	} catch (error) {
		console.error(`   [API] Lỗi lấy mật khẩu từ Blockchain: ${error.message}`);
		return res.status(500).json({ error: error.message });
	}
});

// ========================================
// PHẦN 2: HỆ THỐNG TỰ ĐỘNG (CLOCKER)
// ========================================

async function scanAndProcess() {
	console.log(`\n[CLOCKER] [${new Date().toLocaleTimeString()}] Bắt đầu quét hệ thống...`);

	try {
		await withFabricContract(async (contract) => {
			const resultBytes = await contract.evaluateTransaction('GetAllContracts');
			const resultString = decoder.decode(resultBytes);

			if (!resultString || resultString.length === 0) {
				console.log('   [CLOCKER] Không tìm thấy contract nào.');
				return;
			}

			let bookings = [];
			try {
				const parsed = JSON.parse(resultString);
				bookings = Array.isArray(parsed) ? parsed : [];
			} catch (error) {
				console.error(`   [CLOCKER] Dữ liệu contract không hợp lệ: ${error.message}`);
				return;
			}
			const now = getCurrentTimestamp();

			console.log(`   [CLOCKER] Tìm thấy ${bookings.length} đơn hàng trên Blockchain.`);

			for (const booking of bookings) {
				// AUTO CHECK-IN
				if (booking.Status === 'CREATED' && now >= booking.StartDate) {
					console.log(`   [CLOCKER] Phát hiện đơn ${booking.id} đến giờ Check-in!`);

					const newPass = randomPassword(6);
					const newPassHash = hashPassword(newPass);

					try {
						await contract.submitTransaction('CheckIn', booking.id, newPassHash);
						// Cập nhật Firebase: căn hộ OCCUPIED, hợp đồng ACTIVE
						const apartment = await ApartmentRepository.getById(booking.ApartmentID);
						if (apartment) {
							await ApartmentRepository.update(apartment.Id, { Status: 'OCCUPIED', Password: newPass });
						}
						const firestoreContract = await ContractRepository.getById(booking.id);
						if (firestoreContract) {
							await ContractRepository.update(firestoreContract.Id, 
								{ 
									Status: 'ACTIVE', 
									UpdateDate: admin.firestore.Timestamp.now()
								});
						}
						console.log(`       [CLOCKER] AUTO CHECK-IN THÀNH CÔNG: ${booking.id}`);
						console.log(`       [CLOCKER] Mật khẩu cho khách: ${newPass}`);
					} catch (err) {
						console.error(`       [CLOCKER] Lỗi khi Check-in ${booking.id}: ${err.message}`);
					}
				}

				// AUTO CHECK-OUT
				if (booking.Status === 'ACTIVE' && now >= booking.EndDate) {
					console.log(`   [CLOCKER] Phát hiện đơn ${booking.id} đến giờ Check-out!`);

					const resetPass = randomPassword(7);
					const resetPassHash = hashPassword(resetPass);

					try {
						await contract.submitTransaction('CheckOut', booking.id, resetPassHash);
						// Cập nhật Firebase: giải ngân, hoàn tất hợp đồng, căn hộ AVAILABLE
						const firestoreContract = await ContractRepository.getById(booking.id);
						const apartment = await ApartmentRepository.getById(booking.ApartmentID);
						if (firestoreContract) {
							const ownerId = apartment?.UserID;
							if (ownerId) {
								const owner = await UserRepository.getById(ownerId);
								if (owner) {
									const nextBalance = (owner.Balance || 0) + (firestoreContract.EscrowAmount || 0);
									await UserRepository.update(owner.Id, { Balance: nextBalance });
								}
							}
							await ContractRepository.update(firestoreContract.Id, {
								EscrowAmount: 0,
								Status: 'COMPLETED',
								UpdateDate: admin.firestore.Timestamp.now(),
							});
						}
						if (apartment) {
							await ApartmentRepository.update(apartment.Id, { Status: 'AVAILABLE', Password: resetPass });
						}
						console.log(`       [CLOCKER] AUTO CHECK-OUT THÀNH CÔNG: ${booking.id}`);
						console.log('       [CLOCKER] Tiền đã được giải ngân cho chủ nhà.');
						console.log(`       [CLOCKER] Mật khẩu reset thành: ${resetPass}`);
					} catch (err) {
						console.error(`       [CLOCKER] Lỗi khi Check-out ${booking.id}: ${err.message}`);
					}
				}
			}
		});
	} catch (error) {
		console.error(`[CLOCKER] Lỗi hệ thống: ${error.message}`);
	}
}

// ========================================
// KHỞI ĐỘNG HỆ THỐNG
// ========================================

async function main() {
	console.log('=== KHỞI ĐỘNG HỆ THỐNG TÍCH HỢP ===');
	console.log('API Gateway đang chạy tại cổng', PORT);
	console.log(`URL cho IoT: POST http://<IP_MAY_TINH>:${PORT}/api/verify`);
	console.log('Clocker: Chu kỳ quét 60 giây/lần');

	// Khởi động API Server
	app.listen(PORT, () => {
		console.log('\nServer đã sẵn sàng!');
	});

	// Quét ngay lần đầu
	await scanAndProcess();

	// Cài đặt lặp lại mỗi 60 giây
	setInterval(async () => {
		await scanAndProcess();
	}, 60000);
}

main().catch(console.error);
