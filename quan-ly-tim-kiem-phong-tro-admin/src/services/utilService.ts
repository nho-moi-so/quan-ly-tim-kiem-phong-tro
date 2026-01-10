import { existsSync } from "fs";
import { mkdir, writeFile } from "fs/promises";
import { join } from "path";

export const UtilService = {
    uploadFile: async (file: File): Promise<{
        url: string;
        filename: string;
        size: number;
        type: string;
    }> => {
        // Validate file
        if (!file || file.size === 0) {
            throw new Error("File is empty or invalid");
        }

        const bytes = await file.arrayBuffer();
        const buffer = Buffer.from(bytes);

        // Create unique filename
        const timestamp = Date.now();
        const originalName = file.name.replace(/\s+/g, '-');
        const filename = `${timestamp}-${originalName}`;

        // Ensure upload directory exists
        const uploadDir = join(process.cwd(), "public", "uploads");
        if (!existsSync(uploadDir)) {
            await mkdir(uploadDir, { recursive: true });
        }

        // Save file
        const filePath = join(uploadDir, filename);
        await writeFile(filePath, buffer);

        // Return file info
        return {
            url: `/uploads/${filename}`,
            filename: filename,
            size: file.size,
            type: file.type
        };
    }
};