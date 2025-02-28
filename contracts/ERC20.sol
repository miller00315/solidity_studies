// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Token {
    
    ///@return supply total amount of token
    function totalSupply() external view returns (uint256 supply) {}

    ///@param _owner The address from which the balance will be retrived
    ///@return balance the balance
    function balanceOf(address _owner) external view virtual returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer as successful or not
    function transfer(address _to, uint256 _value) external virtual returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender, uint256 _value) external virtual returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external virtual returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 internal totalSupply;

    function transfer(address _to, uint256 _value) external override returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

     function transferFrom(address _from, address _to, uint256 _value) external override returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) external view override returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) external override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}

 contract MillerToken is StandardToken{
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    uint256 public unitsOneEthCanBuy;     // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC).
    uint256 public totalEthInWei;         // We'll store the total ETH raised via our ICO here.
    address public fundsWallet;           // Where should the raised ETH go?

    // This is a constructor function
    // which means the following function name has to match the contract name declared above
    constructor() {
        balances[msg.sender] = 100000000000;             // Give the creator all initial tokens. This is set to 1000 for example.
                                                                  // If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)
        totalSupply = 100000000000;                  // Update total supply (1000 for example) (CHANGE THIS)
        name = "MillerToken";                                        // Set the name for display purposes (CHANGE THIS)
        decimals = 18;                                             // Amount of decimals for display purposes (CHANGE THIS)
        symbol = "MCOKN";                                           // Set the symbol for display purposes (CHANGE THIS)
        unitsOneEthCanBuy = 10;              // Set the price of your token for the ICO (CHANGE THIS)
        fundsWallet = msg.sender;                                  // The owner of the contract gets ETH
    }

    receive() external payable {
        totalEthInWei += msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount, "Not enough tokens in the fund wallet");

        balances[fundsWallet] -= amount;
        balances[msg.sender] += amount;

        emit Transfer(fundsWallet, msg.sender, amount);

        payable(fundsWallet).transfer(msg.value);
    }

    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData) external returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        (bool successCall, ) = _spender.call(
            abi.encodeWithSelector(bytes4(keccak256("receiveApproval(address,uint256,address,bytes)")), msg.sender, _value, address(this), _extraData)
        );
        require(successCall, "Approval call failed");
        return true;
    }

}