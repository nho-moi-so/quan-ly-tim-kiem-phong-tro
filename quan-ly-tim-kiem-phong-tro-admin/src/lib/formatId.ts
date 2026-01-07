
export const formatId = {
    formatPostId: (id: string): string => {
        return id.slice(0, 8).toUpperCase();
    },
    formatUserId: (id: string): string => {
        return id.slice(0, 6).toUpperCase();
    }
}