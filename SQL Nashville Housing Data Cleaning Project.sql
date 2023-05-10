/*

Nashville Housing Data Cleaning Project

*/


-- Standardize Date Format
-- Using CONVERT Function to change data type and add new column to table
SELECT SaleDate
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing


-- Populate Property Address Data
-- Using a self join to find the null address values with the same parcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Update the table using the ISNULL Function to input the addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Property Address into Individual Columns using Substrings
SELECT PropertyAddress
FROM NashvilleHousing

-- Using Substring to locate ',' Then taking everything from the index 1 position to the index at -1 (',') to remove the ',' itself
-- Using Substring to locate ',' again but this time taking everything from the ','(+1) position until the end of the address column (LEN)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS StreetAddress, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS State
FROM NashvilleHousing

-- Update Table with these new columns
ALTER TABLE NashvilleHousing
Add StreetAddress NVARCHAR(255), StateAddress NVARCHAR(255)  

UPDATE NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1), StateAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Breaking out Owner Address into Individual Columns using ParseName
SELECT OwnerAddress
FROM NashvilleHousing

-- Using Parsename but also Replace to look for '.' instead of the default ',' working in reverse at Parsname starts from end
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

-- Update Table with these new columns
ALTER TABLE NashvilleHousing
Add OwnerStreetAddress NVARCHAR(255), OwnerCityAddress NVARCHAR(255), OwnerStateAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in SoldAsVacant to be in line with other responses
-- Using CASE to change the values where appropriate
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant 
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing

-- Update Table using the CASE query
UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- Removing Duplicates
-- Find duplicates using the row_number with partition by over selected columns
-- View duplicates using the query in a CTE and looking for results >1 indicating a duplicate
WITH duplicate AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
						) row_num
FROM dbo.NashvilleHousing
)
SELECT *
FROM duplicate
WHERE row_num > 1
ORDER BY PropertyAddress


-- Deleting Unused Columns from Table
-- Always first check data that is being removed from Table
SELECT OwnerAddress, TaxDistrict, PropertyAddress
FROM NashvilleHousing

-- Delete Columns
ALTER TABLE NashvilleHousing
DROP COlUMN OwnerAddress, TaxDistrict, PropertyAddress

-- Check Results
SELECT *
FROM NashvilleHousing

