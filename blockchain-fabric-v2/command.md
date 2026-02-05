
cd test-network
./network.sh createChannel -c rentingchannel //khong viet hoa, khong _, khong khoang trang
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/chaincode/ -ccl go 


