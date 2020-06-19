pragma solidity ^0.5.0;

import "openzeppelin/contracts/access/Roles.sol";

contract TeamRole {
    // Libraries
    using Roles for Roles.Role;

    // Events
    event TeamRoleAdded(address indexed account);
    event TeamRoleRemoved(address indexed account);

    // Variables
    Roles.Role private _teamMember;

    // Constructor
    constructor () public {
        _addTeamMember(msg.sender);
    }

    // Modifier
    modifier isTeam() {
        require(isTeamMember(msg.sender), "Caller is not part of the Team");
        _;
    }

    modifier isNotTeam() {
        require(!isTeamMember(msg.sender), "Caller is part of the Team");
        _;
    }

    // Public Functions
    function isTeamMember(address account) public view returns (bool) {
        return _teamMember.has(account);
    }

    function addTeamMember(address account) public isTeam {
        _addTeamMember(account);
    }

    function renounceTeamMember() public isTeam{
        _removeTeamMember(msg.sender);
    }

    // Internal Functions
    function _addTeamMember(address account) internal {
        _teamMember.add(account);
        emit TeamRoleAdded(account);
    }

    function _removeTeamMember(address account) internal {
        _teamMember.remove(account);
        emit TeamRoleRemoved(account);
    }
}
