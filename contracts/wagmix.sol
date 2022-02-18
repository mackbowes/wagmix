//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Wagmix is ERC1155 {
    uint256 private _currentTokenID = 0;
    string public name;

    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => string) public tokenURIs;
    mapping(uint256 => uint256) public numTokenTransfersById;

    constructor(string memory _name) ERC1155("") {
        name = _name;
    }

    modifier creatorOnly(uint256 _id) {
        require(creators[_id] == msg.sender, "Not Creator");
        _;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return tokenURIs[_id];
    }

    function create(address _initialOwner, string calldata _uri)
        external
        returns (uint256)
    {
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = msg.sender;

        if (bytes(_uri).length > 0) {
            tokenURIs[_id] = _uri;
            emit URI(_uri, _id);
        }

        tokenSupply[_id] = 1;
        _mint(_initialOwner, _id, 1, "");
        numTokenTransfersById[_id]++;
        return _id;
    }

    function share(address _to, uint256 _id) external creatorOnly(_id) {
        tokenSupply[_id] += 1;
        _mint(_to, _id, 1, "");
    }

    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID + 1;
    }

    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; i++) {
            if (numTokenTransfersById[ids[i]] >= tokenSupply[ids[i]]) {
                revert("Wagmix tokens are soulbound.");
            }
        }
    }
}
