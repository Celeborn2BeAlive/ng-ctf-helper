// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "../src/EliteVeTokenDeadManSwitch.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EliteVeTokenDeadManSwitchTest is Test {
    EliteVeTokenDeadManSwitch public dmSwitch;

    address veTokenOwner = address(0x42);
    address operator = address(0x543);
    address veTokenRecipient = address(0xc2ba);

    VotingEscrowMock veToken;
    VoterMock voter;

    uint256 veTokenId;

    function setUp() public {
        veToken = new VotingEscrowMock();
        veTokenId = 1337;
        veToken.mint(veTokenOwner, veTokenId);
        voter = new VoterMock(veToken);
        dmSwitch = new EliteVeTokenDeadManSwitch(
            veToken,
            voter,
            operator,
            veTokenRecipient,
            veTokenId
        );
    }

    // Access control
    function testRevertWhenUnallowedSetTimeBeforeDead(address badActor, uint256 time) public {
        vm.assume(badActor != operator);
        vm.prank(badActor);
        vm.expectRevert();
        dmSwitch.setTimeBeforeDead(time);
    }

    function testRevertWhenUnallowedSetOperator(address badActor, address newOperator) public {
        vm.assume(badActor != operator);
        vm.prank(badActor);
        vm.expectRevert();
        dmSwitch.setOperator(newOperator);
    }

    function testRevertWhenUnallowedSetVeTokenRecipient(address badActor, address newRecipient) public {
        vm.assume(badActor != operator);
        vm.prank(badActor);
        vm.expectRevert();
        dmSwitch.setVeTokenRecipient(newRecipient);
    }

    function testRevertWhenUnallowedSetVeTokenId(address badActor, uint256 newTokenId) public {
        vm.assume(badActor != operator);
        vm.prank(badActor);
        vm.expectRevert();
        dmSwitch.setVeTokenId(newTokenId);
    }

    // Admin

    function testSetOperator(address newOperator) public {
        vm.prank(operator);
        dmSwitch.setOperator(newOperator);
        assertEq(dmSwitch.operator(), newOperator);

        vm.prank(newOperator);
        dmSwitch.setOperator(operator);
        assertEq(dmSwitch.operator(), operator);
    }

    function testRevertWhenSetZeroOperator() public {
        vm.prank(operator);
        vm.expectRevert();
        dmSwitch.setOperator(address(0));
    }

    function testSetTimeBeforeDead(uint256 newTime) public {
        vm.prank(operator);
        dmSwitch.setTimeBeforeDead(newTime);
        assertEq(dmSwitch.timeBeforeDead(), newTime);
    }

    function testSetVeTokenRecipient(address newVeTokenRecipient) public {
        vm.prank(operator);
        dmSwitch.setVeTokenRecipient(newVeTokenRecipient);
        assertEq(dmSwitch.veTokenRecipient(), newVeTokenRecipient);
    }

    function testRevertWhenSetZeroVeTokenRecipient() public {
        vm.prank(operator);
        vm.expectRevert();
        dmSwitch.setVeTokenRecipient(address(0));
    }

    function testSetVeTokenId(uint256 newVeTokenId) public {
        vm.prank(operator);
        dmSwitch.setVeTokenId(newVeTokenId);
        assertEq(dmSwitch.veTokenId(), newVeTokenId);
    }

    // Features

    function testRevertWhenSaveVeTokenBeforeDead(address badActor) public {}

    function testSaveVeTokenTransfersToRecipientWhenOperatorIsDead() public {}

    function testSaveVeTokenResetsVeTokenBeforeTransfer() public {}

    function testIsEnabledWhenApproved() public {
        assertEq(dmSwitch.isEnabled(), false);

        vm.prank(veTokenOwner);
        veToken.approve(address(dmSwitch), veTokenId);

        assertEq(dmSwitch.isEnabled(), true);
    }

    function testIsEnabledWhenApprovedForAll() public {
        assertEq(dmSwitch.isEnabled(), false);

        vm.prank(veTokenOwner);
        veToken.setApprovalForAll(address(dmSwitch), true);

        assertEq(dmSwitch.isEnabled(), true);
    }

    function testEllapsedTimeSinceLastVote() public {}

    function testAreYouDeadYet() public {}
}

contract VotingEscrowMock is ERC721, IVotingEscrow {
    mapping(uint256 => bool) resetFlag;

    constructor() ERC721("VotingEscrowMock", "veNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
        resetFlag[tokenId] = true;
    }

    function isApprovedOrOwner(address _spender, uint256 _tokenId) external view returns (bool) {
        return _spender == ownerOf(_tokenId) || getApproved(_tokenId) == _spender
            || isApprovedForAll(ownerOf(_tokenId), _spender);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override(ERC721, IERC721) {
        require(resetFlag[_tokenId], "attached");
        super.transferFrom(_from, _to, _tokenId);
    }

    function setResetFlag(uint256 _tokenId, bool _value) public {
        resetFlag[_tokenId] = _value;
    }
}

contract VoterMock is IVoter {
    VotingEscrowMock veToken;
    mapping(uint256 => uint256) public lastVoted;

    constructor(VotingEscrowMock _veToken) {
        veToken = _veToken;
    }

    function vote(uint256 _tokenId) external {
        lastVoted[_tokenId] = block.timestamp;
        veToken.setResetFlag(_tokenId, false);
    }

    function reset(uint256 _tokenId) external {
        veToken.setResetFlag(_tokenId, true);
    }
}
