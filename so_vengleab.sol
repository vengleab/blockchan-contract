pragma solidity >=0.4.25 <0.6.0;

contract LoyaltyCoin {
    uint ONE_LOY = 1;
    uint ONE_USD = ONE_LOY * 100;
    uint ONE_ETHER_DOLLAR = 300;
    uint ONE_ETHER_LOY = ONE_USD * ONE_ETHER_DOLLAR;
    uint MIN_REGISTERATION_AMOUNT = ONE_USD * 200;
    uint MERCHANT_ID = 1;
    
	mapping (uint => Merchant) stores;
	mapping(address => uint) public loyBalances;
	address payable manager;
	
	constructor() public {
	    manager = msg.sender;
	}

    struct Merchant {
        mapping(address => uint) tokens;
        uint MERCHANT_ID;
        uint totalToken;
        string name;
        bool isRegisterMerchant;
    }
    
    // ====================== MODIFIER METHOD  =====================    
    modifier isRegisterMerchant(uint merchantId) {
        require(stores[merchantId].isRegisterMerchant, "The merchant is not registered");
        _;
    }
    
    modifier isManager() {
        require(msg.sender == manager, "You are not manager");
        _;
    }
    
    modifier isEnoughLoy( address spender, uint amount) {
        require(loyBalances[spender] >= amount, "Not enough loy");
        _;
    }
    
    modifier isSenderHasEnoughToken(uint merchantId, uint amount) {
        require(getSenderToken(merchantId) >= amount, "You do not have enough token at merchant");
        _;
    }
    
    modifier isEnoughToken(address spender, uint merchantId, uint amount) {
        require(getToken(spender, merchantId) >= amount, "You do not have enough token at merchant");
        _;
    }
    
    // ====================== PRIVATE METHOD  =====================  
    
    // TO-DO: to tranfer to manager
    function transferEtherToManager(uint numberOfWei) private{
        //manager.transfer(numberOfWei);
    }
    
    function spendLoy( address spender, uint loy) isEnoughLoy(spender, loy) private {
        loyBalances[spender] = loyBalances[spender] - loy;
    }
    
    function spendToken( address spender, uint merchantId, uint tokens) isEnoughToken(spender, merchantId, tokens) private {
       stores[merchantId].tokens[spender] = getToken(spender, merchantId) + tokens;
    }
    
    function getToken( address spender, uint merchantId) private view returns (uint) {
        return stores[merchantId].tokens[spender];
    }
    
    function getSenderToken(uint merchantId) private view returns (uint) {
        return stores[merchantId].tokens[msg.sender];
    }
    
    function getSpendToken(uint loyAmount) private returns (uint) {
        return loyAmount / 100;
    }
    
    function addMerchanToken(uint merchantId, uint amount) private {
        stores[merchantId].totalToken = stores[merchantId].totalToken + amount; 
    }
    
    function addSpenderToken(uint merchantId, address spender, uint amount) private {
        stores[merchantId].tokens[spender] = stores[merchantId].tokens[spender] + amount; 
    }
    function deductSpenderToken(uint merchantId, address spender, uint amount) private {
        stores[merchantId].tokens[spender] = stores[merchantId].tokens[spender] - amount; 
    }
    
    function addSpender(uint merchantId, uint amount) private {
        stores[merchantId].totalToken = stores[merchantId].totalToken + amount; 
    }
    
    function getExhangeLoy(uint token) private returns (uint) {
        return token * 6 / 10;
    }
    // ===========================================    
    

    // ====================== PUBLIC METHOD  =====================    
    
    
    function loadFromEther(uint etherAmount) public {
        transferEtherToManager(1 ether * etherAmount);
        loyBalances[msg.sender] = loyBalances[msg.sender] + etherAmount * ONE_ETHER_LOY;
    }
    
    function loadFromEtherForMerchant(uint etherAmount, uint merchantId) isRegisterMerchant(merchantId) public {
        transferEtherToManager(1 ether * etherAmount);
        stores[merchantId].totalToken = etherAmount * ONE_ETHER_LOY;
    }

    function registerMerchant(string memory merchantName)  public {
        transferEtherToManager((1 ether)*200/ONE_ETHER_DOLLAR);
        
        stores[MERCHANT_ID++] = Merchant({
            totalToken: MIN_REGISTERATION_AMOUNT,
            name: merchantName,
            MERCHANT_ID: MERCHANT_ID,
            isRegisterMerchant: true
        });
    }
    
    function getMerchantInfo(uint merchantId) isRegisterMerchant(merchantId) public view returns (
       uint Id, string memory name, uint totalToken
    ) {
        return (stores[merchantId].MERCHANT_ID, stores[merchantId].name, stores[merchantId].totalToken);
    }
    
    function geCustomerTokenAtMerchant(uint merchantId) isRegisterMerchant(merchantId) public view returns (
       uint totalToken
    ) {
        return (stores[merchantId].tokens[msg.sender]);
    }
    
    function buyFromMerchant(uint merchantId, uint amount) isRegisterMerchant(merchantId) public {
        spendLoy(msg.sender, amount);
        uint token = getSpendToken(amount);
        addMerchanToken( merchantId, amount - token);
        addSpenderToken(merchantId, msg.sender, token);
    }
    
    function getMyLoyBalance() public view returns( uint) {
        return loyBalances[msg.sender];
    }
    
    // User must input the value by calculate them self, otherwise some token will be lost
    function exchangeTokenToLoy(uint merchantId, uint token) isRegisterMerchant(merchantId) isSenderHasEnoughToken(merchantId, token) public {
        uint loy = getExhangeLoy(token);
        
        loyBalances[msg.sender] = loyBalances[msg.sender] + loy;
        deductSpenderToken(merchantId, msg.sender,token);
    }
}
