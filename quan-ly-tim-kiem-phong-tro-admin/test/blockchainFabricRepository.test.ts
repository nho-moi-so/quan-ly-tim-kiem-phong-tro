import { Contract } from 'fabric-network';

import {
    BlockchainFabricRepository,
    IApartment,
    IContract,
    IUser,
} from '../src/repositories/blockchainFabricRepository';

type MockedContract = {
	submitTransaction: jest.Mock;
	evaluateTransaction: jest.Mock;
} & Partial<Contract>;

const makeContract = (): MockedContract => ({
	submitTransaction: jest.fn(),
	evaluateTransaction: jest.fn(),
});

describe('BlockchainFabricRepository', () => {
	let contract: MockedContract;
	let repo: BlockchainFabricRepository;

	beforeEach(() => {
		contract = makeContract();
		repo = new BlockchainFabricRepository(contract as Contract);
	});

	it('createUser submits correct args', async () => {
		await repo.createUser('U1', 'An', 1000, 'GUEST');

		expect(contract.submitTransaction).toHaveBeenCalledWith(
			'CreateUser',
			'U1',
			'An',
			'1000',
			'GUEST'
		);
	});

	it('getUserById parses buffer json', async () => {
		const user: IUser = {
			docType: 'user',
			id: 'U1',
			fullName: 'An',
			balance: 1000,
			lockedBalace: 0,
			status: 'ACTIVE',
			role: 'GUEST',
		};

		contract.evaluateTransaction.mockResolvedValue(
			Buffer.from(JSON.stringify(user))
		);

		const result = await repo.getUserById('U1');

		expect(result).toEqual(user);
		expect(contract.evaluateTransaction).toHaveBeenCalledWith('GetUserById', 'U1');
	});

	it('updateUserById submits and parses response', async () => {
		const updated: IUser = {
			docType: 'user',
			id: 'U2',
			fullName: 'Binh',
			balance: 500,
			lockedBalace: 0,
			status: 'LOCKED',
			role: 'OWNER',
		};

		contract.submitTransaction.mockResolvedValue(
			Buffer.from(JSON.stringify(updated))
		);

		const result = await repo.updateUserById('U2', 'Binh', 'LOCKED', 'OWNER');

		expect(contract.submitTransaction).toHaveBeenCalledWith(
			'UpdateUserById',
			'U2',
			'Binh',
			'LOCKED',
			'OWNER'
		);
		expect(result).toEqual(updated);
	});

	it('deposit/requestWithdraw/finishWithdraw submit numbers as strings', async () => {
		await repo.deposit('U1', 200);
		await repo.requestWithdraw('U1', 150);
		await repo.finishWithdraw('U1', 50);

		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			1,
			'Deposit',
			'U1',
			'200'
		);
		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			2,
			'RequestWithDraw',
			'U1',
			'150'
		);
		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			3,
			'FinishWithDraw',
			'U1',
			'50'
		);
	});

	it('createApartment and updatePasswordApartment submit correctly', async () => {
		await repo.createApartment('A1', 'O1', 300);
		await repo.updatePasswordApartment('A1', 'hash');

		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			1,
			'CreateApartment',
			'A1',
			'O1',
			'300'
		);
		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			2,
			'UpdatePasswordApartment',
			'A1',
			'hash'
		);
	});

	it('getApartmentById parses buffer json', async () => {
		const apartment: IApartment = {
			docType: 'apartment',
			id: 'A1',
			ownerId: 'O1',
			dailyRate: 300,
			status: 'AVAILABLE',
			passwordHash: 'hash',
		};

		contract.evaluateTransaction.mockResolvedValue(
			Buffer.from(JSON.stringify(apartment))
		);

		const result = await repo.getApartmentById('A1');

		expect(result).toEqual(apartment);
		expect(contract.evaluateTransaction).toHaveBeenCalledWith('GetApartmentById', 'A1');
	});

	it('verifyAccess converts string result to boolean', async () => {
		contract.evaluateTransaction.mockResolvedValue(Buffer.from('true'));
		const ok = await repo.verifyAccess('A1', 'hash');

		contract.evaluateTransaction.mockResolvedValue(Buffer.from('false'));
		const bad = await repo.verifyAccess('A1', 'hash');

		expect(ok).toBe(true);
		expect(bad).toBe(false);
	});

	it('bookApartment/checkIn/checkOut/cancelBooking submit correctly', async () => {
		await repo.bookApartment('C1', 'A1', 'U1', 100, 200);
		await repo.checkIn('C1', 'hash-in');
		await repo.checkOut('C1', 'hash-out');
		await repo.cancelBooking('C1');

		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			1,
			'BookApartment',
			'C1',
			'A1',
			'U1',
			'100',
			'200'
		);
		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			2,
			'CheckIn',
			'C1',
			'hash-in'
		);
		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			3,
			'CheckOut',
			'C1',
			'hash-out'
		);
		expect(contract.submitTransaction).toHaveBeenNthCalledWith(
			4,
			'CancelBooking',
			'C1'
		);
	});

	it('getAllContracts parses list', async () => {
		const contracts: IContract[] = [
			{
				docType: 'contract',
				id: 'C1',
				apartmentId: 'A1',
				guestId: 'U1',
				startDate: 100,
				endDate: 200,
				escrowAmount: 500,
				status: 'CREATED',
			},
		];

		contract.evaluateTransaction.mockResolvedValue(
			Buffer.from(JSON.stringify(contracts))
		);

		const result = await repo.getAllContracts();

		expect(result).toEqual(contracts);
		expect(contract.evaluateTransaction).toHaveBeenCalledWith('GetAllContracts');
	});
});
