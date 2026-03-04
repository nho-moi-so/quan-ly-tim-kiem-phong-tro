
cd test-network
./network.sh down

docker rm -f $(docker ps -aq --filter name=peer) 
docker rm -f $(docker ps -aq --filter name=orderer) 
docker rm -f $(docker ps -aq --filter name=cli) 
docker volume rm $(docker volume ls -q | grep example.com)


./network.sh createChannel -c rentingchannel -ca //khong viet hoa, khong _, khong khoang trang
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go 
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go -ccv 2.0 -ccs 2

trước khi tắt máy: docker stop $(docker ps -aq)
mở máy lại: docker start $(docker ps -aq)


peer chaincode query -C rentingchannel -n renting -c '{"function":"GetUserById","Args":["dSbOpLyc0IO3Be9Ci9DMidE8i7b2"]}'


