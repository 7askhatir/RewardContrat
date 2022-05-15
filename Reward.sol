// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract RewardCon{
    ERC20 public rewardsToken;
    uint day=86400;
    uint mount=30;
    struct Reward{
        uint amount;
        uint time;
    }
    event claim(uint _amount);
    event sendRewards(uint _amount);
    address owner;

    constructor(address _rewardsToken) {
        rewardsToken = ERC20(_rewardsToken);
        owner=msg.sender;
    }

    mapping (address => Reward) Allrewards;


    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function newDate()  public view returns(uint){
       return block.timestamp;
    }
      function _owner() public view virtual returns (address) {
        return owner;
    }
     modifier onlyOwner() {
        require(_owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function changeOwner(address _newOwner) public onlyOwner {
        owner=_newOwner;
    }
     function setReward(address _user,uint _amount) public {
         if(Allrewards[_user].time ==0 )
         Allrewards[_user]=Reward(_amount,newDate());
         else Allrewards[_user].amount+=_amount;
     }

     function getReward(address _user) public view returns(Reward memory _reward){
         _reward = Allrewards[_user];
     }
     function lastClaim(address _user) public view returns (uint u){
           Reward memory reward=getReward(_user);
          return (mount-(newDate()-reward.time)/day);
     }
     function claimReward(address _user) public {
         uint last = lastClaim(_user);
         uint amount = getReward(_user).amount;
         require(amount>0 ,"your Reward is empty" );
         if(last <= 30)amount =amount/100*(100-last);
         _safeTransferFrom(rewardsToken,owner,_msgSender(),amount);
          Allrewards[_user].amount-=amount;
          Allrewards[_user].time=newDate();
          emit claim(amount);
     }
     function _safeTransferFrom(
        ERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        require(sender != address(0),"address of sender Incorrect ");
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }

    function _balanceOfTokenReward(address _user) private view returns(uint){
        require(_user != address(0),"address of sender Incorrect ");
        uint balance =rewardsToken.balanceOf(_user);
        return balance;
    }

    function sendRewardForAllHolders(address[] memory _holders,uint _amount ) public onlyOwner{
        for(uint i=0;i<_holders.length;i++){
            uint amount = _balanceOfTokenReward(_holders[i])*_amount/_toutalSupplay();
            setReward(_holders[i],amount);
        }
        emit sendRewards(_amount);
    }

    function _toutalSupplay() private view returns (uint) {
        return rewardsToken.totalSupply();
    }


    // function getUserIds(uint _reward ,address _user) public {
    //     users[_user].rewards.push(_reward);
    // }
    // function setUserIds(address _user) public view returns(uint[] memory  reward){
    //   return users[_user].rewards;
    // }
    // function deletIdRewardForUser(uint rewardId,address _user) public  {
    //     for(uint i=0;i<users[_user].rewards.length;i++){
    //        if(users[_user].rewards[i]==rewardId){
    //           delete users[_user].rewards[i];
    //        }
    //     }
    // }
    // function getReward(Reward memory _reward,uint _id) public {
    //     Allrewards[_id]=_reward;
    // }
    // function setReward(uint _id) public view returns(Reward memory) {
    //     return Allrewards[_id];
    // }
    // function sendRewardToUser(address _user ,Reward memory _reward) public {
    //      id++;
    //      getReward(_reward,id);
    //      getUserIds(id,_user);
    // }

    // function getAllRewaedByUser(address _user) public view returns(Reward[] memory){
    //     uint[] memory listIds= setUserIds(_user);
    //     Reward[] memory result = new Reward[](listIds.length);
    //     for(uint i=0;i<listIds.length;i++){
    //         result[i]=setReward(listIds[i]);
    //     }
    //     return result;
    // }

    // function addRewardForAllUser(address[] memory _users,uint _amount) public{
    //     for(uint i=0;i<_users.length;i++){
    //       Reward memory _reward=Reward(block.timestamp,_amount,version);
    //       sendRewardToUser(_users[i],_reward);
    //     }
    //     version++;
    // }
    // function claimReward(uint _idRewaed) public {
    //     Reward memory reward=setReward(_idRewaed);
    //     uint ageOfReward=block.timestamp-reward.time;

    //     rewardsToken.transfer(msg.sender, 18);
    // }

}
