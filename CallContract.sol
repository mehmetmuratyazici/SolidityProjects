// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract CallContract {
    address contractAddr;
    address usdtAddr;
    event CallResponse(bool success, uint256 data);

    constructor(address _usdtAddr, address _cAddr) {
        contractAddr = _cAddr;
        usdtAddr = _usdtAddr;
    }

    function transferERC20(IERC20 token,address _to, uint256 _amount) public {
        token.transfer( _to, _amount);
        //usdtAddr.delegatecall(abi.encodeWithSignature("transfer(address,uint256)", _to, _amount));
    }

    receive() external payable {}

    function payableMoney() public payable {}

    function setContractAddress(address _cAddr) public {
        contractAddr = _cAddr;
    }

    function sendMoney() public returns (bool) {
        return IUsdt(usdtAddr).transfer(address(this), getAmount());
    }

    function sendMoney2(address _addr, uint256 _amount) public returns (bool) {
        (bool success, bytes memory data) = usdtAddr.delegatecall(
            abi.encodeWithSignature("transfer(address,uint256)", _addr, _amount)
        );
        //emit CallResponse(success, abi.decode(data, (bool)));
        return success;
    }

    function allowlance(address _owner, address _spender) public returns (uint256) {
        (bool success, bytes memory data) = usdtAddr.delegatecall(
            abi.encodeWithSignature("allowance(address,address)", _owner, _spender)
        );
        emit CallResponse(success, abi.decode(data, (uint256)));
        return abi.decode(data, (uint256));
    }

    function getSender() public returns (address) {
        (bool success, bytes memory data) = contractAddr.delegatecall(
            abi.encodeWithSignature("currentSender()")
        );

        return abi.decode(data, (address));
    }

    function getBalance() public view returns (uint256) {
        return IUsdt(usdtAddr).balanceOf(msg.sender);
    }

    function getOtherContractAddres() public view returns (address) {
        return ITutorial(contractAddr).getAddress();
    }

    function getAmount() public view returns (uint256) {
        return ITutorial(contractAddr).getAmount();
    }
}


interface ITutorial {
    function changeAmountValue(uint256 _val) external;

    function getAddress() external view returns (address);

    function getTime() external view returns (uint256);

    function getAmount() external view returns (uint256);

    function currentSender() external view returns (address);
}

interface IUsdt {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
}
