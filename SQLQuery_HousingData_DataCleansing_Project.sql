--In Data Cleansing, following things are done :)
--we have change the formatting of a datatype like "datetime" To "date",
--creating new columns like SaleDateConverted,
--delete not used columns like SaleDate,
--change some values in particular column like "Y" To "Yes",
--breaking single column into multiple columns which contains multivalue like OwnerAddress,
--remove duplicates records,
--assign values which contains NULL by use of some conditions, etc.
--USE of Functions like Substring, left ,right ,trim, charindex, parsename, isnull, row_number, convert, cast etc


--Viewing all data for Data Cleaning
SELECT * FROM PortfolioProject..NashvilleHousing



-------------------------------------------------------------------------------------------
--Standardize Date Format

--Checking here how it change look like
SELECT SaleDate, CONVERT(Date, SaleDate), CAST(SaleDate AS DATE)
FROM PortfolioProject..NashvilleHousing


--Here we have made a change to it.
UPDATE PortfolioProject..NashvilleHousing
SET SaleDate =  CAST(SaleDate AS DATE)


--Above not worked, so we have choosing other method.And It's worked.

--Adding a new column to this table
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE


--Here we have made a change to it.
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--It's working perfectly fine
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing



-------------------------------------------------------------------------------------------
--Populate Property Address Data


SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL



---------------------------------------------------------------------------------------------------
--Breaking out PropertyAddress into individual columns(Address, City)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress,1)-1) AS [Address],
TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress,1)+1, LEN(PropertyAddress) - CHARINDEX(',',PropertyAddress,1) )) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress,1)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)


UPDATE NashvilleHousing
SET PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress,1)+1, LEN(PropertyAddress) - CHARINDEX(',',PropertyAddress,1) ))



--------------------------------------------------------------------------------------------------------------------
--Breaking out OwnerAddress into individual columns(Address, City, State)
--1st method
SELECT OwnerAddress, LEFT(OwnerAddress, CHARINDEX(',',OwnerAddress,1)-1),
SUBSTRING(OwnerAddress, CHARINDEX(',',Owneraddress,1)+2,CHARINDEX(',',Owneraddress,CHARINDEX(',',Owneraddress,1)+2) - CHARINDEX(',',Owneraddress,1)-2),
RIGHT(OwnerAddress,LEN(OwnerAddress) - CHARINDEX(',',OwnerAddress,CHARINDEX(',',OwnerAddress,1)+1) -1)
FROM PortfolioProject..NashvilleHousing

--2nd method
--Checking before applying to the existing table
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing
--Here 3 new columns created and then adding values to those created columns.

--Creating 1st Column "OwnerSplitAddress"
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

--adding values to created above column
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


--Creating 2nd Column "OwnerSplitCity"
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

--adding values to created above column
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


--Creating 3rd Column "OwnerSplitState"
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

--adding values to created above column
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--viewing the upgraded data after separating single column into 3 separate columns
SELECT OwnerAddress, OwnersplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousing



-------------------------------------------------------------------------------------------------------------------
--Change Y To Yes and N To NO in "SoldAsVacant" Column

SELECT DISTINCT SoldAsVacant
FROM PortfolioProject..NashvilleHousing


SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
(CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END) AS UpdatedSoldVsVacant
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = (CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END)



------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RemoveDup
AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY 
					ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
			 ORDER BY
					UniqueID ASC) AS rowdupfinder
FROM PortfolioProject..NashvilleHousing
)
SELECT *--DELETE
FROM RemoveDup
WHERE rowdupfinder > 1



----------------------------------------------------------------------------------------------------------------
--Delete The Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing