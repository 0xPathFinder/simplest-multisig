//SPDX-License-Identifier: MIT 
pragma solidity 0.8.0; 
 
contract PrimitiveMultiSig{ 
 
    mapping(address => bool) public isOwner; 
 
    uint public numbersOfConfirmation = 0; 
 
    uint public timeLeft; 
 
    address ownerNumberOne; 
    address ownerNumberTwo;  
 
    modifier onlyFirstOwner() { 
        require(msg.sender == ownerNumberOne, "NOT ownerNumberOne"); 
        _; 
    } 
 
    modifier onlySecondOwner() { 
        require(msg.sender == ownerNumberTwo, "NOT ownerNumberTwo"); 
        _; 
    } 
 
    event firstOwnerApproved(address indexed _firstOwnerEvent); 
    event secondOwnerApproved(address indexed _secondOwnerEvent); 
    event revokeFirstOwnerApproved(address indexed _firstOwnerEvent); 
    event revokeSecondOwnerApproved(address indexed _secondOwnerEvent); 
    event Deposit(address indexed _fromEvent); 
    event Withdrawn(address indexed _destinationEvent, uint _amountEvent); 
 
    constructor(address _confirmedOwnerNumberOne, address _confirmedOwnerNumberTwo){ 
        ownerNumberOne = _confirmedOwnerNumberOne; 
        ownerNumberTwo = _confirmedOwnerNumberTwo; 
        require(_confirmedOwnerNumberOne != _confirmedOwnerNumberTwo, "CANNOT BE SAME OWNER"); 
        isOwner[_confirmedOwnerNumberOne] = true; 
        isOwner[_confirmedOwnerNumberTwo] = true; 
    } 
 
    function getBalance() public view returns(uint){ 
        return address(this).balance; 
    } 
 
    function currentTime() public view returns(uint) { 
        return block.timestamp; // 43200 = 12 hours 
    } 
 
    function firstOwnerApprove() public onlyFirstOwner { 
        require(numbersOfConfirmation == 0,"ALREADY CONFIRMED BY ownerNumberOne"); 
        ++numbersOfConfirmation; 
        emit firstOwnerApproved(msg.sender); 
    } 
 
    function revokeFirstOwnerApprove() public onlyFirstOwner{ 
        if (numbersOfConfirmation == 1) { 
            --numbersOfConfirmation; 
        } 
        emit revokeFirstOwnerApproved(msg.sender); 
    } 
 
    function secondOwnerApprove() public onlySecondOwner { 
        require(numbersOfConfirmation == 1, "NOT CONFIRMED BY ownerNumberOne YET"); 
        ++numbersOfConfirmation; 
        timeLeft = currentTime() + 43200; 
        emit secondOwnerApproved(msg.sender); 
    } 
 
    function revokeSecondOwnerApprove() public onlySecondOwner { 
        if (numbersOfConfirmation == 2) { 
            --numbersOfConfirmation; 
        } 
        emit revokeSecondOwnerApproved(msg.sender); 
    } 
 
    function withdrawn(address payable _destination, uint _amount) external { 
        require(msg.sender == ownerNumberOne || msg.sender == ownerNumberTwo, "NOT AN OWNER"); 
        require(numbersOfConfirmation == 2, "TWO CONFIRMATIONS REQUIRED"); 
 
        if (currentTime() < timeLeft) { 
            _destination.transfer(_amount); 
            emit Withdrawn(msg.sender, _amount); 
        } 
        numbersOfConfirmation = 0; 
        timeLeft = 0; 
    } 
 
    receive() external payable{ 
        emit Deposit(msg.sender); 
    } 
 
}
