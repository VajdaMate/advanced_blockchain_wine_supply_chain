// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

contract BottleStore{
    struct Bottle {
        address owner;
        uint128 bottleId;
        string typeOfGrape;
        uint32[] sunnyHours;
        uint32[] rainMilimeters;
        string[] timeOfHarvest;
        string[] timeOfBottling;
    }
    
    Bottle[] public bottles;
    
    
    //Registerhez
    function registerBottle(uint128 _bottleId, string memory _typeOfGrape) public {
        uint32[] memory tmpSunny = new uint32[](1); 
        tmpSunny[0] = 0;
        uint32[] memory tmpRain = new uint32[](1);
        tmpRain[0] = 0;
        string[] memory tmpTimeOfHarvest = new string[](1);
        tmpTimeOfHarvest[0] = "M\u00e9g nem sz\u00fcretelt";
        string[] memory tmpTimeOfBottling = new string[](1);
        tmpTimeOfBottling[0] = "M\u00e9g nem palackozott";

        bottles.push(Bottle(msg.sender,_bottleId,_typeOfGrape,tmpSunny,tmpRain,tmpTimeOfHarvest,tmpTimeOfBottling));
    }

    function registerBottle(
        uint128 _bottleId, string memory _typeOfGrape, 
        uint32[] memory _sunnyHours, uint32[] memory _rainMilimiters, 
        string[] memory _timeOfHarvest, string[] memory _timeOfBottling) public 
    {
        bottles.push(Bottle(msg.sender,_bottleId,_typeOfGrape,_sunnyHours,_rainMilimiters,_timeOfHarvest,_timeOfBottling));
    }


    function returnLastBottleID()public view returns (uint128){
        return bottles[bottles.length-1].bottleId;
    }
    
    
    //Checkhez, updatehez
    function returnBottleByID(uint256 _id)public view returns (Bottle memory){
        for (uint128 i = 0; i < bottles.length; i++) {
            if (bottles[i].bottleId == _id) {
               return bottles[i];
            }
        }
    }

    //Checkhez
    function ownersBottles() public view returns (Bottle[] memory){
        uint count=0;
        for (uint i = 0; i < bottles.length; i++) {
            if (bottles[i].owner == msg.sender) {
               count++;
            }
        }

        Bottle[] memory tempBottles = new Bottle[](count);
        uint tempCount=0;
        for (uint i = 0; i < bottles.length; i++) {
            if (bottles[i].owner == msg.sender) {
                tempBottles[tempCount]=bottles[i];
                tempCount++;
            }
        }

        return tempBottles;
    }

    //Updatehez

    function updateSunnyHours(uint256 _id, uint32 _sunnyHours) public {
         uint128 tempId;
         for (uint128 i = 0; i < bottles.length; i++) {
            if (bottles[i].bottleId == _id) {
                tempId=i;
                break;
            }
        }
        require(bottles[tempId].owner == msg.sender, "Csak saj\u00E1t \u00FCveget friss\u00EDthetsz!"); //Unicode karakterek
        
        bottles[tempId].sunnyHours.push(_sunnyHours);
    }

    function updateRainMilimeters(uint256 _id, uint32 _rainMilimeters) public {
        uint128 tempId;
         for (uint128 i = 0; i < bottles.length; i++) {
            if (bottles[i].bottleId == _id) {
                tempId=i;
                break;
            }
        }
        
        require(bottles[tempId].owner == msg.sender, "Csak saj\u00E1t \u00FCveget friss\u00EDthetsz!");
       
        bottles[tempId].rainMilimeters.push(_rainMilimeters);
    }

    function updateTimeOfHarvest(uint256 _id, string memory _timeOfHarvest) public {
        uint128 tempId;
         for (uint128 i = 0; i < bottles.length; i++) {
            if (bottles[i].bottleId == _id) {
                tempId=i;
                break;
            }
        }
        require(bottles[tempId].owner == msg.sender, "Csak saj\u00E1t \u00FCveget friss\u00EDthetsz!");
        bottles[tempId].timeOfHarvest.push(_timeOfHarvest);
    }

    function updateTimeOfBottling(uint256 _id, string memory _timeOfBottling) public {
        uint128 tempId;
         for (uint128 i = 0; i < bottles.length; i++) {
            if (bottles[i].bottleId == _id) {
                tempId=i;
                break;
            }
        }
        require(bottles[tempId].owner == msg.sender, "Csak saj\u00E1t \u00FCveget friss\u00EDthetsz!");
      
        bottles[tempId].timeOfBottling.push(_timeOfBottling);
    }


    //Tulajváltás
    function giveBottle(uint256 _id, address _newOwner) public {
        uint128 tempId;
         for (uint128 i = 0; i < bottles.length; i++) {
            if (bottles[i].bottleId == _id) {
                tempId=i;
                break;
            }
        }
        
        require(bottles[tempId].owner == msg.sender, "Csak saj\u00E1t \u00FCveget adhatsz!");
        bottles[tempId].owner = _newOwner;
    }


}