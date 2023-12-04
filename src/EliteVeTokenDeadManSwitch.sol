// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// References
// Retro:
// - Voter (proxy): https://polygonscan.com/address/0xaccba5e852ab85e5e3a84bc8e36795bd8cec5c73
// - Voter (implementation VoterV3): https://polygonscan.com/address/0x71f6cac5c79a9af50f47df0568c075a6055ba830#code
// - VotingEscrow: https://polygonscan.com/address/0xB419cE2ea99f356BaE0caC47282B9409E38200fa#code
// elRETRO Depositor:
// - https://polygonscan.com/address/0xcc835d13543cec819ac0226dd9ff35b6312b8fca#code

contract EliteVeTokenDeadManSwitch {
    IVotingEscrow public immutable veToken;
    IVoter public immutable voter;

    uint256 public timeBeforeDead = 30 days;
    address public operator;
    address public veTokenRecipient;
    uint256 public veTokenId;

    constructor(
        IVotingEscrow _veToken,
        IVoter _voter,
        address _operator,
        address _veTokenRecipient,
        uint256 _veTokenId
    ) {
        require(_operator != address(0));
        require(_veTokenRecipient != address(0));

        veToken = _veToken;
        voter = _voter;
        operator = _operator;
        veTokenRecipient = _veTokenRecipient;
        veTokenId = _veTokenId;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Not operator");
        _;
    }

    function ellapsedTimeSinceLastVote() public view returns (uint256) {
        return block.timestamp - voter.lastVoted(veTokenId);
    }

    function areYouDeadYet() public view returns (bool) {
        // https://www.youtube.com/watch?v=aNJXS9X0yY0
        return ellapsedTimeSinceLastVote() > timeBeforeDead;
    }

    function setTimeBeforeDead(uint256 _time) external onlyOperator {
        timeBeforeDead = _time;
    }

    function setOperator(address _operator) external onlyOperator {
        require(_operator != address(0));
        operator = _operator;
    }

    function setVeTokenRecipient(address _veTokenRecipient) external onlyOperator {
        require(_veTokenRecipient != address(0));
        veTokenRecipient = _veTokenRecipient;
    }

    function setVeTokenId(uint256 _tokenId) external onlyOperator {
        veTokenId = _tokenId;
    }

    function isEnabled() external view returns (bool) {
        return veToken.isApprovedOrOwner(address(this), veTokenId);
    }

    function saveVeToken() external {
        require(areYouDeadYet(), "Not dead yet !");
        voter.reset(veTokenId);
        address owner = veToken.ownerOf(veTokenId);
        veToken.safeTransferFrom(owner, veTokenRecipient, veTokenId);
    }
}

interface IVoter {
    function reset(uint256 _tokenId) external;

    function lastVoted(uint256 _tokenId) external view returns (uint256);
}

interface IVotingEscrow is IERC721 {
    function isApprovedOrOwner(address _spender, uint256 _tokenId) external view returns (bool);
}
