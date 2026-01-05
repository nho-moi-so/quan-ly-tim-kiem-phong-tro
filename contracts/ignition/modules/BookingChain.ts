import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BookingChainModule", (m) => {
  const bookingChain = m.contract("BookingChain");

  return { bookingChain };
});
