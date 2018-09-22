pragma solidity ^0.4.24;

import "../../math/SafeMath.sol";
import "../Crowdsale.sol";
import "../../ownership/Ownable.sol";

/**
 * @title PersonalCappedCrowdsale
 * @dev This contract is like IndividuallyCappedCrowdsale but the same cap for everyone.
 * IF YOU USE THIS CONTRACT, IT IS NOT REALLY RELIABLE TO USE IndividuallyCappedCrowdsale.
 * So don't use both, select one of them.
 */
 
contract PersonalCappedCrowdsale is Ownable, Crowdsale {
  using SafeMath for uint256;
  
  mapping(address => uint256) private _contributions;
  uint256 personalLimit;
  
  /**
   * @dev Sets the cap.
   * @param limit is the cap.
   * BUG If owner changes the limit when crowdsale was open and limit was higher,
   * then before the change anyone can contribute more than the new limit.
  */
  function setLimit(uint256 limit) external onlyOwner {
      personalLimit = limit;
  }
  
  /**
   * @dev Returns the current cap.
   * @return Current Cap for everyone.
   */
  function getLimit() public view returns (uint256) {
      return personalLimit;
  }
  
  /**
   * @dev Returns the contributed amount in wei.
   * @param beneficiary is the address you want to check.
   * @return The contribution of the account in wei.
   */
  function getContribution(address beneficiary) public view returns (uint256) {
      return _contributions[beneficiary];
  }
  
  /**
   * @dev Extend parent behavior requiring purchase to respect the contribution limit.
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    super._preValidatePurchase(beneficiary, weiAmount);
    /**
     * We can add a if control becuase if owner does not sets a cap
     * then every contribution will be returned by here.
     * Because the personalLimit uint256 is set 0 by default.
     */
    require(_contributions[beneficiary].add(weiAmount) <= personalLimit);
  }
  
  /**
   * @dev Extend parent behavior to update beneficiary contributions
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _updatePurchasingState(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    super._updatePurchasingState(beneficiary, weiAmount);
    _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
  }
}
