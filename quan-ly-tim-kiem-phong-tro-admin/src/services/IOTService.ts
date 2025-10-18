export const IOTService = {
    verifyPassword: async (password: string, roomCode: string) => {
        //== set cung mat khau la "123456" de test
        return {
            status: password === "123456" ? "success" : "fail",
            message: password === "123456" ? "welcome IOT" : "byebye IOT"
        }
    }
}