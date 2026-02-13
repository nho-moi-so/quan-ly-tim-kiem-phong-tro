
cd test-network
./network.sh down

docker rm -f $(docker ps -aq --filter name=peer)
docker rm -f $(docker ps -aq --filter name=orderer)
docker rm -f $(docker ps -aq --filter name=cli)
docker volume rm $(docker volume ls -q | grep example.com)

sudo rm -rf organizations/peerOrganizations
sudo rm -rf organizations/ordererOrganizations
sudo rm -rf channel-artifacts

./network.sh createChannel -c rentingchannel //khong viet hoa, khong _, khong khoang trang
./network.sh deployCC -c rentingchannel -ccn renting -ccp ../chaincode-go/ -ccl go 



