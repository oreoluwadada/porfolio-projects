/* 

Cleaning Data in SQL Queries

*/

(SELECT *
FROM NashvilleHousing);

-- Standardize Date Format
UPDATE NashvilleHousing
SET Saledate = DATE_FORMAT(STR_TO_DATE(saledate,"%M %d,%Y" ),"%Y/%m/%d" );

-- Populate Property Address data
UPDATE NashvilleHousing
Set PropertyAddress = nullif(PropertyAddress,'');

(SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null
order by ParcelID );

(SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UNiqueID
Where a.PropertyAddress is null);

UPDATE NashvilleHousing a 
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UNiqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
Where a.PropertyAddress is null;

-- Breaking out Adderess Into Individual Columns (Address, City, State)
(SELECT PropertyAddress
FROM NashvilleHousing);

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)) as Address
FROM NashvilleHousing;
	-- (or more succintly)
SELECT
SUBSTRING_INDEX(PropertyAddress, ',', 1) as Address,
SUBSTRING_INDEX(PropertyAddress, ',', -1) as Address
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1); 

(SELECT OwnerAddress
FROM NashvilleHousing);

SELECT 
substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1), 
substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) 
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255),
ADD OwnerSplitCity Nvarchar(255),
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1);

UPDATE NashvilleHousing
SET OwnerSplitCity = substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1); 

UPDATE NashvilleHousing
SET OwnerSplitState = substring_index(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

-- Change Y and N to Yes and No in "Sold as Vacant" field

(Select distinct(soldasvacant), count(soldasvacant)
from NashvilleHousing
group by 1
order by 2);

Select soldasvacant,  
Case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No' 
     else soldasvacant
     end
from NashvilleHousing;

Update NashvilleHousing
SET soldasvacant =  Case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No' 
     else soldasvacant
     end;
     
-- Remove Duplicates 
With RowNumCTE as 
(SELECT *, row_number() over(
partition by ParcelID,
			PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            order by UniqueID) as row_num
FROM NashvilleHousing
)

Delete 
From RowNumCTE
where row_num > 1;

-- Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress;

 