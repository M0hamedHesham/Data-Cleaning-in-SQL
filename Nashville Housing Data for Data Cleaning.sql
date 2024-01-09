/*

Cleaning data in SQL queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------

--Standardize Data Format

SELECT
	SaleDate,
CONVERT(DATE,SaleDate) AS SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)


-----------------------------------------------------------

--Populate property address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
	A.ParcelID,
	A.PropertyAddress,
	B.ParcelID,
	B.PropertyAddress,
	ISNULL(A.PropertyAddress , B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress , B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing as A
JOIN PortfolioProject.dbo.NashvilleHousing as B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--------------------------------------------------------------------------

--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT 
PARSENAME ( REPLACE (OwnerAddress, ',', '.') , 3)
	AS OwnerSplitAddress ,
PARSENAME ( REPLACE (OwnerAddress, ',', '.') , 2)
	AS OwnerSplitCity ,
PARSENAME ( REPLACE (OwnerAddress, ',', '.') , 1)
	AS OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME ( REPLACE (OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME ( REPLACE (OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME ( REPLACE (OwnerAddress, ',', '.') , 1)

-------------------------------------------------------------------------------------------------------------

--Chang Y and N to Yes AND No in "sold as vacant"

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
	SoldAsVacant, 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-------------------------------------------------------------------------

-- Create a copy of the table
SELECT *
INTO PortfolioProject..Test_NashvilleHousing
FROM PortfolioProject..NashvilleHousing

SELECT *
FROM PortfolioProject..Test_NashvilleHousing
--ORDER BY PropertyAddress


--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		ORDER BY
			UniqueID
			) AS row_num
--FROM PortfolioProject..Test_NashvilleHousing
FROM PortfolioProject..NashvilleHousing
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM PortfolioProject..Test_NashvilleHousing

ALTER TABLE PortfolioProject..Test_NashvilleHousing
DROP COLUMN 
	PropertyAddress,
	SaleDate,
	OwnerAddress,
	TaxDistrict