/* Moving data from CSV to Postgres and 
Cleaning Data in SQL Queries
*/
-- creating table and adding columns
ALTER TABLE public."NashvilleHousing"
ADD column halfbath decimal;

ALTER TABLE public."NashvilleHousing"
DROP COLUMN halfbath;

ADD column LegalReference VARCHAR(255),
ADD column SoldAsVacant VARCHAR(100),
ADD column OwnerName VARCHAR(100),
ADD column OwnerAddress VARCHAR(100),
ADD column Acreage DECIMAL,
ADD column TaxDistrict VARCHAR(100),
ADD column LandValue INTEGER,
ADD column BuildingValue INTEGER,
ADD column TotalValue INTEGER,
ADD column YearBuilt INTEGER,
ADD column Bedrooms INTEGER,
ADD column FullBath INTEGER,
ADD column HalfBath INTEGER;

SELECT *
FROM "NashvilleHousing"

copy public."NashvilleHousing" FROM '/Users/pearl/downloads/Nashville Housing Data for Data Cleaning.csv' DELIMITER ','CSV HEADER;


-- Standardize Date Format and parcelid column


Select saledate, CAST(saledate AS DATE ) AS SaleDateConverted
From "NashvilleHousing"


Update "NashvilleHousing"
SET saledate = CAST(saledate AS DATE ) 

Update "NashvilleHousing"
SET "ParcelID" = CAST("ParcelID" AS VARCHAR(100) ) 
--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From "NashvilleHousing"
WHERE PropertyAddress is NULL
order by "ParcelID" 



Select a."ParcelID", a.PropertyAddress, b."ParcelID", b.PropertyAddress, CASE WHEN a.propertyaddress IS NULL THEN b.propertyaddress ELSE a.propertyaddress END AS newadd

--if a.propertyadress is null populate with b.propadd
From "NashvilleHousing" AS a
JOIN "NashvilleHousing" AS b
	on a."ParcelID" = b."ParcelID" --where the parcelid's are identical but on different rows by using a unique id column
	AND a."UniqueID " != b."UniqueID " 
Where a.PropertyAddress is null

-- update and replace all null values with propertyadress

	
UPDATE "NashvilleHousing" a
SET propertyaddress = b.propertyaddress
FROM "NashvilleHousing" b
WHERE a."ParcelID" = b."ParcelID"
  AND a."UniqueID " != b."UniqueID "
  AND a.propertyaddress IS NULL
  ; 

----------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From "NashvilleHousing"
order by "ParcelID"

SELECT SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1, LENGTH(PropertyAddress)) as Address

From "NashvilleHousing"


ALTER TABLE "NashvilleHousing"
Add PropertySplitAddress VARCHAR(255);

Update "NashvilleHousing"
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1)


ALTER TABLE "NashvilleHousing"
Add PropertySplitCity VARCHAR(255);

Update "NashvilleHousing"
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1, LENGTH(PropertyAddress))




Select *
From "NashvilleHousing"




Select OwnerAddress
From "NashvilleHousing"




SELECT SPLIT_PART(OwnerAddress, ',', 1), 
SPLIT_PART(OwnerAddress, ',', 2)
From "NashvilleHousing"

ALTER TABLE "NashvilleHousing"
Add Firstowner VARCHAR(255);

Update "NashvilleHousing"
SET Firstowner = SPLIT_PART(OwnerAddress, ',', 1)


ALTER TABLE "NashvilleHousing"
Add SecondOwner varchar(255);

Update "NashvilleHousing"
SET SecondOwner = SPLIT_PART(OwnerAddress, ',', 2)




Select *
From "NashvilleHousing"

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From "NashvilleHousing"
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From "NashvilleHousing"


Update "NashvilleHousing"
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID",
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference --partition by the things you expect to be repeated
				 ORDER BY
					"UniqueID " --order by a unique column
					) row_num --In the output, if any row has the value of [DuplicateCount] column greater than 1, 
								--it shows that it is a duplicate row.

From "NashvilleHousing"
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From "NashvilleHousing"
-- Delete Unused Columns



Select *
From "NashvilleHousing"


ALTER TABLE "NashvilleHousing"
DROP COLUMN OwnerAddress,
DROP COLUMN taxdistrict,
DROP COLUMN PropertyAddress;





