pragma solidity ^0.4.0;

contract visibilityTest {
    function visibilityTest(){

    }

    uint public myNum;
    

    function fn() {
        myNum = 666;
    }

    //不加修饰符，默认为public
    function publicFn() {

    }

    function privateFn() private {

    }

    function innerFn() internal{

    }

    function outerFn() external {

    }


    function callInternal() {
        innerFn();
    }

    function callExternal() {
        //this.innerFn();/*报错，TypeError: Member "innerFn" not found or not visible after argument-dependent lookup in contract visibilityTest，声明了内部调用方式，所以不能用this*/
        //outerFn();//报错,DeclarationError: Undeclared identifier.
        this.outerFn();/*正确，不会报错，因为函数定义时为external(尽管在同一个合约中)*/
    }

    function callPublic() {
        publicFn();     //internal调用方式可以
        this.publicFn();//external调用方式也可以
    }
    function callPrivate() {
        privateFn();

        //this.privateFn();/*报错，TypeError: Member "privateFn" not found or not visible after argument-dependent lookup in contract visibilityTest*/

    }

}

contract visibilityTest2 {
    function callFromOuterContract() {
        visibilityTest vT;
        vT.fn(); //external调用方式
        vT.outerFn();//external调用方式

        //vT.innerFn();//TypeError: Member "innerFn" not found or not visible after argument-dependent lookup in contract visibilityTest,声明了调用方式，不可外部调用
    }
}

contract vTson is visibilityTest {
    function callInherit() {
        //继承，直接调用
        publicFn();
        innerFn();

        //private方式
        //privateFn();//报错，DeclarationError: Undeclared identifier.

        //外部方式
        //outerFn();//报错，DeclarationError: Undeclared identifier.
        this.outerFn();//正确调用方法，与在合约内时一样

        visibilityTest father;
        father.outerFn();//不报错
        
        //father.privateFn();/*报错，TypeError: Member "privateFn" not found or not visible after argument-dependent lookup in contract visibilityTest*/

    }
}