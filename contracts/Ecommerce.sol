//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;


contract ECommerce{
    address payable public owner; // This is the address of the person who deployed this contract

   constructor() {
        owner = payable(msg.sender);
    }
    struct User{
       uint256 user_id;
       string name;
       string Address;
       uint256 mobile;
   }

   struct Product{
    uint256 product_id;
    string productName;
    uint256 quantity;
    uint256 productValue;
    string productCategory;
    address payable owner;
   }

   uint256 ActiveUserId;
   address[] funders;
   User[] internal users;
   Product[] internal productsArr;
   mapping(uint256 => Product) public products;
   Product[] internal AvailableCategoryProducts;
   mapping(address=>uint256) public addressToOwnerFunds;

   uint256[] public bagArr;
   mapping(uint256=>uint256) internal bagProducts;
  
   uint256 totalBill;
   function fundEth() public payable  {
      funders.push(msg.sender);
       addressToOwnerFunds[msg.sender]=msg.value;
    }
 
   function withdrawEth() public payable {      
    uint256 balanceWithdraw=addressToOwnerFunds[msg.sender];
    require(balanceWithdraw>0,"Insufficient funds for withdrawal");
    payable(address(msg.sender)).transfer(balanceWithdraw);    
}
 
  function createUser(string memory name,string memory Address,uint256 mobile) public payable { // memory used for address and name as they are array of characters
        uint256 userid=users.length+1;
        users.push(User(userid,name,Address,mobile));
    }
 
    function getUser(uint256 userId) public view returns(User memory data){
         for(uint i=0;i<users.length;i++){
             if(users[i].user_id== userId){
                return users[i];
             }
         }
    }
 
    function addProduct(string memory name, string memory category, uint256 value, uint256 quantity) public onlyOwner{
        uint256 productId=productsArr.length+1;
        address sellerAddress=msg.sender;
        products[productId]=Product(productId,name,quantity,value,category,payable(sellerAddress));
        productsArr.push(Product(productId,name,quantity,value,category,payable(sellerAddress)));
    }
      
    function getProducts(string memory category) public returns(Product[] memory){
        if(keccak256(bytes(category))==keccak256(bytes(""))){
            return productsArr;
        }else{
            for(uint i=0;i<productsArr.length;i++){
                if(keccak256(bytes(products[i].productCategory))==keccak256(bytes(category))){
                    AvailableCategoryProducts.push(products[i]);
                }
            }
            return AvailableCategoryProducts;
        }
      
    }
   
 
    function AddtoBag(uint256 prodId,uint256 quantity) public {
        require(products[prodId].quantity >= quantity, "Insufficient quantity");
        bagArr.push(prodId);
        bagProducts[prodId]=quantity;
        totalBill+=products[prodId].productValue*quantity;
    }
   
   function showBag() public view returns(Product[] memory)  {
       Product[] memory bagItemsArray=new Product[](bagArr.length);   
       for(uint itemNum=0;itemNum<bagArr.length;itemNum++){
        uint productId=bagArr[itemNum];
        bagItemsArray[itemNum]=products[productId];
       }
       return bagItemsArray;
   }
    
    function checkOutBag() public payable{
        require(totalBill <= msg.value,"Insufficient funds");
        for(uint itemNum=0;itemNum<bagArr.length;itemNum++){
            uint prodId=bagArr[itemNum];
            uint price=(bagProducts[prodId])*(products[prodId].productValue);
            products[itemNum].owner.transfer(price);
        }
    }

    function buyProductNow(uint256 productId,uint256 productQuantity) public payable {
        require(products[productId].quantity >= productQuantity, "Insufficient quantity");
        require(msg.value >= products[productId].productValue * productQuantity, "Insufficient funds");
        products[productId].owner.transfer(msg.value);
        products[productId].quantity-=productQuantity;
    }
    ///#################

    modifier onlyOwner(){
        require(msg.sender==owner,"Only Owner is allowed");
        _;
    }
}