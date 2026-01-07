import { ApartmentRepository } from "@/repositories/apartmentRepository";
import { PostRepository } from "@/repositories/postRepository";
import { UserRepository } from "@/repositories/userRepository";

export const PostService = {

    getAllPosts: async () => {
        const posts = await PostRepository.getAll();
        let result = [];
        for (const post of posts) {
            //tim thông tin của author là chủ căn hộ
            const apartment = await ApartmentRepository.getById(post.ApartmentID);
            // console.log("apartmentID", post.ApartmentID);
            if(!apartment) {
                console.warn("Apartment not found for post " + post.Id);
                continue;
            }
            const user = await UserRepository.getById(apartment.UserID);
            if(!user) {
                console.warn("User not found for apartment " + apartment.Id);
                continue;
            }

            result.push({
                codePost: post.Id,
                title: post.Header || '',
                author: user.Fullname,
                createdAt: post.CreationDate,
                status: post.Status
            });
        }
        return result;
    },

    approvePost: async (postId: string) => {
        const post = await PostRepository.getById(postId);
        if (!post) {
            throw new Error("Post not found");
        }
        
        const updatedPost = await PostRepository.update(postId, {
            Status: "approved"
        });
        
        return {
            codePost: updatedPost.Id,
            status: updatedPost.Status
        };
    },

    rejectPost: async (postId: string) => {
        const post = await PostRepository.getById(postId);
        if (!post) {
            throw new Error("Post not found");
        }
        
        const updatedPost = await PostRepository.update(postId, {
            Status: "rejected"
        });
        
        return {
            codePost: updatedPost.Id,
            status: updatedPost.Status
        };
    },

    hidePost: async (postId: string) => {
        const post = await PostRepository.getById(postId);
        if (!post) {
            throw new Error("Post not found");
        }
        
        const updatedPost = await PostRepository.update(postId, {
            Status: "hidden"
        });
        
        return {
            codePost: updatedPost.Id,
            status: updatedPost.Status
        };
    },
    
    getDetailPost: async (postId: string) => {
        const post = await PostRepository.getById(postId);
        if (!post) {
            throw new Error("Post not found");
        }

        const apartment = await ApartmentRepository.getById(post.ApartmentID || '');
        if (!apartment) {
            throw new Error("Apartment not found for the post");
        }

        const user = await UserRepository.getById(apartment.UserID);
        if (!user) {
            throw new Error("User not found for the apartment");
        }

        

        return {
            codePost: post.Id,
            roomNumber: apartment.CodeApartment,
            location: "Khu 4", //== hardcoded for now
            area: "30 m2", //== hardcoded for now
            dailyRate: apartment.DailyRate,
            address: apartment.Address,
            publishDate: formatPublishDate(post.CreationDate),
            status: post.Status,
            description: post.Description,
            imgPath: apartment.PathImage,
        };
    }
};
const formatPublishDate = (ts: any): string => {
            if (!ts) return '';
            const options: Intl.DateTimeFormatOptions = {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
            };

            // Firestore Timestamp has toDate()
            if (typeof ts.toDate === 'function') {
            return ts.toDate().toLocaleString('vi-VN', options);
            }

            // Firebase-like object { _seconds, _nanoseconds } or { seconds, nanoseconds }
            if (typeof ts === 'object' && (('_seconds' in ts) || ('seconds' in ts))) {
            const seconds = (ts._seconds ?? ts.seconds) as number;
            const nanoseconds = (ts._nanoseconds ?? ts.nanoseconds ?? 0) as number;
            const ms = seconds * 1000 + Math.floor(nanoseconds / 1e6);
            return new Date(ms).toLocaleString('vi-VN', options);
            }

            // number (ms) or numeric string
            const num = typeof ts === 'number' ? ts : parseInt(ts, 10);
            if (!Number.isNaN(num)) {
            // if it's in seconds (10 digits), convert to ms
            const ms = String(num).length === 10 ? num * 1000 : num;
            return new Date(ms).toLocaleString('vi-VN', options);
            }

            // fallback: try Date parse
            const d = new Date(ts);
            if (!isNaN(d.getTime())) return d.toLocaleString('vi-VN', options);

            return String(ts);
        };