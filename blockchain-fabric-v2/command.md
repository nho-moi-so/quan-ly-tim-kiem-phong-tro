
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


# Thêm đường dẫn file thực thi
export PATH=${PWD}/../bin:$PATH
# Chỉ định file cấu hình
export FABRIC_CFG_PATH=$PWD/../config/
# Cấu hình chứng chỉ TLS để giao tiếp an toàn
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode query -C rentingchannel -n renting -c '{"function":"GetUserById","Args":["dSbOpLyc0IO3Be9Ci9DMidE8i7b2"]}'



peer channel fetch newest newest_block.pb -c rentingchannel --orderer localhost:7050 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input newest_block.pb --type common.Block | jq '.data.data[0].payload.header.signature_header.creator'

echo "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNwekNDQWsyZ0F3SUJBZ0lVRWhxY1ZWUXo0dzJLM3M1UmlxNGg2akdTZFRjd0NnWUlLb1pJemowRUF3SXc..." | base64 -d | openssl x509 -text -noout

