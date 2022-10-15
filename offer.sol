// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

contract OfferCreate {
    Offer[] public arrOffer;
    event CreatedOfferContract(address _contractAddr, address _offerOwner, uint _amount);
    function createOffer(address offerOwner, uint amount) public returns(address){
        Offer offer = new Offer(payable(msg.sender), payable(offerOwner), amount);
        arrOffer.push(offer);

        emit CreatedOfferContract(address(offer), offerOwner, amount);

        return address(offer);
    }

}

contract Offer {

    address payable public contractOwner;
    address payable public offerOwner;
    uint public offerAmount;
    bool checkOwnerContract;
    bool checkOwnerOffer;
    bool isSendRequireMoney;
    enum OfferState {Runnig, Complated, Canceled}
    OfferState public offerState;

    event CheckInProcess(address _addr, bool _val);
    event SendMoney(address _addr, uint _amount);


    constructor(address payable eoa, address payable offerAccount, uint amount) {
        offerAmount = amount;
        contractOwner = eoa;
        offerOwner = offerAccount;
        offerState = OfferState.Runnig;
    }

    receive() payable external{

    }

    modifier notFinished(){
        require(offerState == OfferState.Runnig, "This process is not runnig");
        _;
    }

    modifier mustContractOwner() {
        require(contractOwner == msg.sender, "You must be contract owner!");
        _;
    }

    modifier mustOfferOwner() {
        require(offerOwner == msg.sender, "You must be offer owner!");
        _;
    }

    modifier mustOwner() {
        require((offerOwner == msg.sender || contractOwner == msg.sender), "You must be owner!");
        _;
    }

    function sendMoney() public payable mustOfferOwner notFinished {
        require(msg.value == offerAmount, "your sent money amount must be offerAmount !");
        isSendRequireMoney = true;
        emit SendMoney(msg.sender, msg.value);
    }

    function changeOfferAmount(uint newAmount) public mustContractOwner notFinished returns(bool) {
        offerAmount = newAmount;
        return true;
    }

    function isComplated() public view mustOwner returns(bool){
        return checkOwnerContract && checkOwnerOffer;
    }

    function checkIn() public mustOwner notFinished returns(bool){
        if(msg.sender == contractOwner)
            checkOwnerContract = !checkOwnerContract;
        if(msg.sender == offerOwner)
            checkOwnerOffer = !checkOwnerOffer;

        if(isComplated()){
            complateProcess();
        }

        emit CheckInProcess(msg.sender, checkOwnerContract || checkOwnerOffer);

        return checkOwnerContract || checkOwnerOffer;
    }

    function complateProcess() private mustOwner notFinished {
        contractOwner.transfer(address(this).balance);
        offerState = OfferState.Complated;
    }

    function cancelOfferContract() public mustContractOwner notFinished returns(bool) {
        offerState = OfferState.Canceled;
        return true;
    }
}