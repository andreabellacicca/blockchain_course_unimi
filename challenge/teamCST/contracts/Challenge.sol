pragma solidity ^0.5.0;

import "./TeamRole.sol";
import "openzeppelin/contracts/math/SafeMath.sol";
import "./PayCoin.sol";
import "./Exchange.sol";
// (da importare Exchange e PayCoin)

contract Challenge is TeamRole {
    // Libraries
    using SafeMath for uint256;

    // Global Variables
    address _PayCoinAddress;
    address _ExchangeAddress;
    address _OurTeamAddress = 0xe6a2234764Bd7a41Da73bd91F9E857819d20b22F;

    mapping (address => bool) _registeredTeams;
    uint256 _numberRegisteredTeams = 0;

    // Variables Overnight Challenge
    uint256 _challenge_price_id;
	uint256 _timeStartOvernight;
    bool _overnightChallengeOpen = false;

    // Variables Direct Challenge
    mapping (uint256 => bool) _flagStoricDirect;            // Has the flag already been used?
    mapping (uint256 => bool) _challengeOpenDirect;         // Is the challenge still open?
    mapping (uint256 => uint256) _timeStartDirect;          // When the challenge started?
    mapping (uint256 => address) _challengedDirect;         // Who has been challenged?
    mapping (uint256 => address) _challengerDirect;         // Who sent the challenge?

    // Variables Team Challenge
    mapping (uint256 => bool) _flagStoricTeam;
    mapping (uint256 => bool) _challengeOpenTeam;
    mapping (uint256 => uint256) _timeStartTeam;
    mapping (uint256 => address) _challengerTeam;         // Who sent the challenge?

    // Events
    event Registered(address indexed teamAddress);
    event Removed(address indexed teamAddress);
    event Overnight(address indexed winner, uint256 indexed coin_won);
    event TeamChallenge(address indexed challenger, uint256 flag);
    event TeamChallengeWon(address indexed winner, uint256 indexed flag, uint256 indexed amount);
    event DirectChallenge(address indexed challenger, address indexed challenged, uint256 _flag);
    event DirectChallengeWon(address indexed winner, uint256 indexed flag, uint256 indexed _amount);

    // Constructor
    constructor (address PayCoinAddress, address ExchangeAddress) public {
        _PayCoinAddress = PayCoinAddress;
        _ExchangeAddress = ExchangeAddress;
    }

    // Functions for registering accounts

    // Register a team account for Team Challenge
    function register(address teamAddress) external isTeam{
        require(_registeredTeams[teamAddress] == false, "Team already registered");
        require(_numberRegisteredTeams < 3, "Too many Teams registered");
        _registeredTeams[teamAddress] = true;
        _numberRegisteredTeams = _numberRegisteredTeams.add(1);
        emit Registered(teamAddress);
    }

    // Remove a team account for Team Challenge
    function remove(address teamAddress) external isTeam{
        require(_registeredTeams[teamAddress] == true, "Team is not registered");
        _registeredTeams[teamAddress] = false;
        _numberRegisteredTeams = _numberRegisteredTeams.sub(1);
        emit Removed(teamAddress);
    }

    // Numbers of teams registered
    function countTeamAddress() public view returns (uint256) {
        return _numberRegisteredTeams;
    }

    // Is the account a registered team?
    function isRegistered(address teamAddress) external view returns(bool){
        return _registeredTeams[teamAddress];
    }

    // Utility Functions
    function setPayCoinAddress (address PayCoinAddress) external isTeam{
        _PayCoinAddress = PayCoinAddress;
    }

    function setExchangeAddress (address ExchangeAddress) external isTeam{
        _ExchangeAddress = ExchangeAddress;
    }

    function getHour() internal returns (uint256){
        uint256 time = block.timestamp;
        time = time.add(2 hours);           // 1 ora per fuso orario e 1 per ora legale
        time = time.mod(1 days);            // Secondi da mezzanotte
        return time.div(1 hours);           // Divido per secondi in un'ora e prendo parte intera
    }

    // Overnight Challenge functions
    function overnightStart(uint256 new_price_diff) external isTeam {
		uint256 hour = getHour();
		require(hour >= 18 || hour < 9, "This challenge can start only between 6pm and 9am.");

		_challenge_price_id = Exchange(_ExchangeAddress).addPrice(new_price_diff);
		_timeStartOvernight = block.timestamp;
		PayCoin(_PayCoinAddress).burnFrom(msg.sender, 200e18);
		_overnightChallengeOpen = true;
	}


	function overnightCheck (uint256 price_id) external {
		uint256 coin_won;

        require(_overnightChallengeOpen == true, "Challenge closed or never started.");
		require(price_id == _challenge_price_id, "Wrong price ID.");

		if (!isTeamMember(msg.sender)) {
			require(now - _timeStartOvernight <= 3600, "Challenge closed.");
			PayCoin(_PayCoinAddress).mint(msg.sender, 1200e18);
			coin_won = 1200e18;
		} else {
			require(now - _timeStartOvernight > 3600, "Wait!");
			PayCoin(_PayCoinAddress).mint(msg.sender, 2000e18);
			coin_won = 2000e18;
		}
		_overnightChallengeOpen = false;
		emit Overnight(msg.sender, coin_won);
	}

    // Direct Challenge Functions
    function challengeStart(address challenged, uint256 flag) external isTeamRegistered{
        require(_flagStoricDirect[flag] == false, "Flag already used");
        require(challenged != msg.sender, "You cannot challenge your own team!");
        _flagStoricDirect[flag] = true;
        _challengeOpenDirect[flag] = true;
        _timeStartDirect[flag] = block.timestamp;
        _challengedDirect[flag] = challenged;
        _challengerDirect[flag] = msg.sender;
        PayCoin(_PayCoinAddress).burnFrom(msg.sender, 50e18);
        emit DirectChallenge(msg.sender, challenged, flag);
    }

    function winDirectChallenge(uint256 flag) external isTeamRegistered returns(bool){
        require(_challengedDirect[flag] == msg.sender || msg.sender == _challengerDirect[flag], 'You are not supposed to parteciate!');
        PayCoin(_PayCoinAddress).burnFrom(msg.sender, 50e18);
        if(_timeStartDirect[flag] + 5 minutes > block.timestamp){
            return false;
        }
        require(_challengeOpenDirect[flag] == true, "Challenge closed or never started");
        _challengeOpenDirect[flag] = false;
        PayCoin(_PayCoinAddress).mint(msg.sender, 1000e18);
        emit DirectChallengeWon(msg.sender, flag, 1000e18);
        return true;
    }

    // Team Challenge Functions
    function challengeStart(uint256 flag) external isTeam{
        require(_flagStoricTeam[flag] == false, "Flag already used");
        _flagStoricTeam[flag] = true;
        _timeStartTeam[flag] = block.timestamp;
        _challengeOpenTeam[flag] = true;
        _challengerTeam[flag] = msg.sender;
        PayCoin(_PayCoinAddress).burnFrom(msg.sender, 100e18);
        emit TeamChallenge(msg.sender, flag);
    }

    function winTeamChallenge(uint256 flag) external isTeamRegistered returns (bool){
        PayCoin(_PayCoinAddress).burnFrom(msg.sender, 100e18);
        if(_timeStartTeam[flag] + 5 minutes > block.timestamp){
            return false;
        }
        require(_challengeOpenTeam[flag] == true, "Challenge closed or never started");          //Devo ritornare false o far fallire?
        uint256 amount = (_OurTeamAddress == msg.sender) ? 1500e18 : 1000e18;
        PayCoin(_PayCoinAddress).mint(msg.sender, amount);
        emit TeamChallengeWon(msg.sender, flag, amount);
        _challengeOpenTeam[flag] = false;
        return true;
    }

    // Modifiers
    modifier isTeamRegistered(){
        require(_registeredTeams[msg.sender] == true, "Team not registered");
        _;
    }

}
