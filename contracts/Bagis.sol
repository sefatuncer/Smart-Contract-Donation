// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract KriptoBagis{
    address owner;
    mapping (address => bool) isManagerAddress;
    mapping (address => Organization) charityAddressInfos;
    address payable[] charityAddresses;
    uint256 totalDonationsAmount;
    uint256 highestDonation;
    address highestDonor;

    enum OrganizationType{
        Education, //0
        Health, //1
        Environment, //2
        Religion, //3
        CivilSociety, //4
        International, //5
        BigInternational, //6
        GovernmentOrganized //7
    }

    struct Organization{
        address payable organizationAddress;
        string organizationName;
        OrganizationType[] organizationTypes;
        bool isValidated;
    }

    event OrganizationAdded(Organization indexed _organization);

    /// Bağış yapan adresi ve bağış miktarını blockchain'de kaydeder
    event Donation(
        address indexed _donor,
        uint256 _value,
        address indexed _destinationAddress
    );

    // Contract'ta tanımlanan manager'ın onayladığı adresin bilgisini blockchian'de kaydeder
    event AddressValidation(
        address indexed _manager,
        address indexed _validatedAddress
    );

    //contracta eklenen manager address bilgisi
    event AddManager(
        address indexed _managerAddress
    );

    //function getOrganization(address payable memory address) public returns ()
    constructor(){
        owner = msg.sender; //Contract'ı deploylayan kişinin kaydının tutulması
        totalDonationsAmount = 0;
        highestDonation = 0;
    }


    function addNewOrganization(
        string memory organizationName, 
        OrganizationType[] memory organizationTypes) 
        CheckNewCharityAddress(payable(msg.sender)) 
        public {
        charityAddressInfos[msg.sender] = Organization({
            organizationAddress: payable(msg.sender),
            organizationName: organizationName,
            organizationTypes: organizationTypes,
            isValidated: false
        });
        charityAddresses.push(payable(msg.sender));
        emit OrganizationAdded(charityAddressInfos[msg.sender]);
    }

    /// Bütün bağış adreslerini döndürür
    /// @return charityAddresses
    function getAddresses() public view returns (address payable[] memory) {
        return charityAddresses;
    }

    function getAddress() public view returns(Organization memory){ //Kaldırılabilir
        return charityAddressInfos[msg.sender];
    }

    
    function getAddressInfos(address payable charityAddress) public view returns (address payable, string memory, OrganizationType[] memory, bool)
    {
        return (charityAddress, charityAddressInfos[charityAddress].organizationName, charityAddressInfos[charityAddress].organizationTypes, charityAddressInfos[charityAddress].isValidated);
    }
      

    //Contract'ı deploylayan adresin doğrulanması için
    modifier restrictToOwner() {
        require(msg.sender == owner, 'Method available only to the to the user that deployed the contract');
        _;
    }

    //Organizasyon cüzdanlarını doğrulayacak adreslerin yetkili olup olmadığını kontrol eder
    modifier isManager(){
        require(isManagerAddress[msg.sender] || msg.sender == owner,'The Address is not authorized manager address');
        _;
    }

    modifier CheckNewCharityAddress(address payable newAddress){
        bool addresNotFound = true;
        for(uint i=0 ; i < charityAddresses.length; i++){
            if(charityAddresses[i] == newAddress){
                addresNotFound = false;
            }
        }
        require(addresNotFound, 'The address added to the contract before!');
        _;
    }

    //Bağış yapılacak adres daha önce contract'a kaydedildi mi?
    modifier checkCharityAddress(address payable destinationAddress) {
        require(charityAddresses.length > 0, 'Currently there are no addresses in the contract');
        bool addresFound = false;
        for(uint i=0 ; i < charityAddresses.length; i++){
            if(charityAddresses[i] == destinationAddress){
                addresFound = true;
            }
        }
        require(addresFound, 'Destination addres did not found in the contract');
        _;
    }

    //Bağış yapılacak adres daha önce contract'a kaydedildi mi?
    modifier checkOtherCharityAddresses(address payable[] memory otherDestinationAddresses) {
        bool addresFound = false;
        for(uint i=0 ; i < charityAddresses.length; i++){
            for(uint j=0; j < otherDestinationAddresses.length; j++)
                if(charityAddresses[i] == otherDestinationAddresses[j]){
                    addresFound = true;
                }
        }
        require(addresFound, 'Destination addres did not found in the contract');
        _;
    }


    //Bağış yapan kişi kendi adresine bağış yapamaz
    modifier validateDestination(address payable destinationAddress) {
        require(msg.sender != destinationAddress, 'Sender and recipient cannot be the same.');
        _;
    }

    //// Validates that the charity index number provided is a valid one.
    ///
    /// @param charityIndex The target charity index to validate. Indexes start from 0 and increment by 1.
    modifier validateCharity(uint256 charityIndex) {
        require(charityIndex <= charityAddresses.length - 1, 'Invalid charity index.');
        _;
    }
    
    /// Validates that the amount to transfer is not zero.
    modifier validateTransferAmount() {
        require(msg.value > 0, 'Transfer amount has to be greater than 0.');
        _;
    }

     /// Validates that the donated amount is within acceptable limits.
    ///
    /// @param donationAmount The target donation amount.
    /// @dev donated amount >= 1% of the total transferred amount and <= 50% of the total transferred amount.
    modifier validateDonationAmount(uint256 donationAmount) {
        require(donationAmount >= msg.value / 100 && donationAmount <= msg.value / 2,
            'Donation amount has to be from 1% to 50% of the total transferred amount');
        _;
    }

    modifier validateDonationPercentage(uint256 mainPercentage) {
        require(mainPercentage > 0 && mainPercentage <= 100,
            'Main percentage must between 0 to 100');
        _;
    }

    /// Parametre ile gelen yüzdeyi ana adrese aktarır, 
    /// yüzdenin geri kalanındaki miktarı ise diğer parametre ile gelen diğer adresler arasında bölüştürür
    ///
    /// @param destinationAddress Ana adres
    /// @param otherAddresses Diğer adresler
    /// @param mainPercentage Ana adrese aktarılacak yüzde
    function deposit(address payable destinationAddress, address payable[] memory otherAddresses, uint256 mainPercentage) public 
    validateDestination(destinationAddress)
    validateTransferAmount() 
    checkCharityAddress(destinationAddress) 
    checkOtherCharityAddresses(otherAddresses) 
    validateDonationPercentage(mainPercentage)  
    payable {


        uint256 donationAmount = (msg.value * mainPercentage) / 100 ;
        uint256 actualDeposit = msg.value - donationAmount;
        uint256 otherAddressAmount = actualDeposit / otherAddresses.length;

        for(uint i=0; i< otherAddresses.length; i++){
            otherAddresses[i].transfer(otherAddressAmount);
        } 
        destinationAddress.transfer(donationAmount);

        emit Donation(msg.sender, donationAmount, destinationAddress);

        totalDonationsAmount += donationAmount;

        if (donationAmount > highestDonation) {
            highestDonation = donationAmount;
            highestDonor = msg.sender;
        }
    }


    /// Ana adrese bağış yapar.
    ///
    /// @param destinationAddress Ana adres
    /// @param mainPercentage Ana adrese aktarılacak yüzde
    function depositDirect(address payable destinationAddress,  uint256 mainPercentage) 
    validateDestination(destinationAddress)
    validateTransferAmount() 
    checkCharityAddress(destinationAddress) 
    validateDonationPercentage(mainPercentage)  
    external payable {


        uint256 donationAmount = msg.value;

        destinationAddress.transfer(donationAmount);

        emit Donation(msg.sender, donationAmount, destinationAddress);

        totalDonationsAmount += donationAmount;

        if (donationAmount > highestDonation) {
            highestDonation = donationAmount;
            highestDonor = msg.sender;
        }
    }

    // /// Parametre ile gelen yüzdeyi ana adrese aktarır, 
    // /// yüzdenin geri kalanındaki miktarı ise parametre olarak gelen organizasyon tipindeki diğer adreslere dağıtır, SADECE doğrulanmış adreslere dağıtır.
    // ///
    // /// @param destinationAddress Ana adres
    // /// @param mainPercentage Ana adrese aktarılacak yüzde
    // /// @param organizationType Bağışın geri kalanının dağıtımı yapılacak organizasyon tipi
    // function deposit(address payable destinationAddress, uint256 mainPercentage, OrganizationType organizationType) public 
    // validateDestination(destinationAddress)
    // validateTransferAmount() 
    // checkCharityAddress(destinationAddress) 
    // validateDonationPercentage(mainPercentage)  
    // payable {


    //     uint256 donationAmount = (msg.value * mainPercentage) / 100 ;
    //     uint256 actualDeposit = msg.value - donationAmount;

    //     uint count = 0;
    //     address payable[] memory tempArray;

    //     for (uint i=0; i < charityAddresses.length; i++){
    //         if(charityAddressInfos[charityAddresses[i]].organizationTypes[0] == organizationType 
    //         && isValidated[charityAddresses[i]]== true 
    //         && charityAddresses[i] != destinationAddress){
    //             count++;
    //             tempArray.push(charityAddresses[i]);
    //         }
    //     }

    //     if(count > 0){
    //         uint256 validatedAddressAmount = actualDeposit / count;

    //         for(uint i=0; i< tempArray.length; i++){
    //             tempArray[i].transfer(validatedAddressAmount);
    //         } 
    //     }
        
    //     destinationAddress.transfer(donationAmount);

    //     emit Donation(msg.sender, donationAmount, destinationAddress);

    //     totalDonationsAmount += donationAmount;

    //     if (donationAmount > highestDonation) {
    //         highestDonation = donationAmount;
    //         highestDonor = msg.sender;
    //     }
    // }

    // function validateCharityAddress(address payable validatingAddress)
    // isManager()
    // checkCharityAddress(validatingAddress) 
    // public {
    //     charityAddressInfos[validatingAddress].isValidated = true;
    //     emit AddressValidation(msg.sender, validatingAddress);
    // }

    // function addManagerAddress(address managerAddress)
    // restrictToOwner()
    // isManager()
    // public {
    //     isManagerAddress[managerAddress] = true;
    //     emit AddManager(managerAddress);
    // }

    /// Returns the total amount raised by all donations (in wei) towards any charity.
    /// @return totalDonationsAmount
    function getTotalDonationsAmount() public view returns (uint256) {
        return totalDonationsAmount;
    }

    /// En yüksek bağışı ve bağış yapanı döndürür
    /// @return (highestDonation, highestDonor)
    function getHighestDonation() public view restrictToOwner() returns (uint256, address payable)  {
        return (highestDonation, payable(highestDonor));
    }


    // Contract'ı bir daha kullanılmamak üzere blockchainden kaldırır
    function destroy() public restrictToOwner() {
        selfdestruct(payable(owner));
    }
}
