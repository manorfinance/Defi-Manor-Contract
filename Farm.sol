pragma solidity ^0.5.0;
pragma solidity ^0.5.0;
import "./Invite.sol";

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TokenFarm {
    string public name = "Dapp Token Farm";
    address public owner;
    address public rewardsender = address(0x487093ed5B41D947FF40f907B3F08514556c6B3f);
    uint256 public duration = 864000; // for 10 days
    uint256 public rewardrate = 23;
    IERC20 public dappToken;
    IERC20 public daiToken;
    AffiliateStorage public invite;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public lastUpdateTime;
    mapping(address => uint256) public rewardpaid;
    mapping(address => uint256) public lastrewardrate;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    //constructor rewarToken and LpToken
    constructor(
        address _dappToken,
        address _lpt,
        address _invite
    ) public {
        dappToken = IERC20(_dappToken);
        daiToken = IERC20(_lpt);
        invite = AffiliateStorage(_invite);
        owner = msg.sender;
    }

    function stakeTokens(uint256 _amount) public {
        // Require amount greater than 0
        require(_amount > stakingBalance[msg.sender], "amount must greater than balance");

        // Trasnfer Mock Dai tokens to this contract for staking
        daiToken.transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // update lastupdatetimes
        lastUpdateTime[msg.sender] = block.timestamp + duration;
        
        //update userrewardrate
        lastrewardrate[msg.sender] = rewardrate;

        // Add user to stakers array *only* if they haven't staked already
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // Unstaking Tokens (Withdraw)
    function unstakeTokens() public {
        // Fetch staking balance
        uint256 balance = stakingBalance[msg.sender];

        // Require amount greater than 0
        require(balance > 0, "staking balance cannot be 0");

        //lock unstake if lastupdatime<blocktime
        require(block.timestamp > lastUpdateTime[msg.sender]);

        // Transfer Mock Dai tokens to this contract for staking
        daiToken.transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;

        // Update staking status
        isStaking[msg.sender] = false;
      }
    }
