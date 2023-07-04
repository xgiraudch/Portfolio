/**** DATA CLEANING PROJECT****/

---------------------------------------------------------------------------


/*** Overview ***/

SELECT * 
FROM Projet2.dbo.NashvilleHousing;

---------------------------------------------------------------------------

/*** SaleDate variable ***/

SELECT SaleDate
FROM Projet2.dbo.NashvilleHousing;

-- We can remove the time from the variable --

SELECT	SaleDate,
		CONVERT (Date, SaleDate)
FROM Projet2.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

-- I dont know why this method doesn't work. Therefore I will use an ALTER statement. --

ALTER TABLE Projet2.dbo.NashvilleHousing ALTER COLUMN SaleDate DATE NULL ; 

SELECT SaleDate
FROM Projet2.dbo.NashvilleHousing;

-- Here, it works --


---------------------------------------------------------------------------------------------------

/*** Let's have a look at the PropertyAddress variable ***/

SELECT PropertyAddress
FROM Projet2.dbo.NashvilleHousing;

SELECT COUNT (*)
FROM Projet2.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;

-- 29 rows have a null PropertyAddress. We could maybe remove these rows but I will to populate these rows for the purpose of this exercise --

-- We can see that a same ParcelID is sometimes used for the same address multiple times. Therefore, I assume that when we have the same ParcelID
-- for two rows but one these rows doesn't have an PropertyAdress, it may be in fact the same Address as the other rows (with the same ParcelID).

-- --> I will replace the NULL value by the PropertyAddress of the rows with the same ParcelID. --


SELECT	a.ParcelID,
		a.PropertyAddress,
		b.ParcelID,
		b.PropertyAddress
FROM Projet2.dbo.NashvilleHousing a
JOIN Projet2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- I create a column with the Property Address of the rows with the same ParcelID. I will the function ISNULL (IFNULL in MySQL). --

SELECT	a.ParcelID,
		a.PropertyAddress,
		b.ParcelID,
		b.PropertyAddress,
		ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM Projet2.dbo.NashvilleHousing a
JOIN Projet2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Now we insert these values into the table --

UPDATE a
SET	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Projet2.dbo.NashvilleHousing a
JOIN Projet2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------

/***  Another problem arises: the PropertyAddress variable combines the address, the city. ***/

-- Let's split the Address --

SELECT PropertyAddress
FROM Projet2.dbo.NashvilleHousing;


SELECT	SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
		SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Projet2.dbo.NashvilleHousing;

--Let's create two new columns with the Address and the City --

ALTER TABLE Projet2.dbo.NashvilleHousing
ADD  PropertySplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD  PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT	PropertySplitAddress,
		PropertySplitCity
FROM Projet2.dbo.NashvilleHousing;



/***  Now, we split the OwnerAddress variable that combines the address, the city and the state ***/

-- This time, we will use the PARSENAME function --

SELECT	PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddressSlit,
		PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCitySplit,
		PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM Projet2.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerCitySplit NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerCitySplit = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerStateSplit NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerStateSplit = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1)


---------------------------------------------------------------------------------------------------------

/*** The SoldAsVacant column needs to be cleaned because we have 'Yes','No' but also 'Y' and 'N' as values. ***/

SELECT DISTINCT(SoldAsVacant)
FROM Projet2.dbo.NashvilleHousing;

SELECT	DISTINCT(SoldAsVacant),
		COUNT(SoldAsVacant)
FROM Projet2.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC;

-- Here our table is rather small. But with a big table, I'd try to be as efficient as possible. I'll therefore replace the least populated (Y,N) by the most populated (Yes, No) --

SELECT	SoldAsVacant,
		CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SoldAsVacant = 'N' THEN 'No'
				ELSE SoldAsVacant
		END AS New
FROM Projet2.dbo.NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


-------------------------------------------------------------------------------------------------------


/*** Removing the duplicates ***/


WITH RowNumCTE AS (
SELECT	*,
		ROW_NUMBER() OVER (PARTITION BY ParcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
										ORDER BY UniqueID
							) row_num

FROM Projet2.dbo.NashvilleHousing
-- ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1



----------------------------------------------------------------------------------------------------

/*** Removing Unused Columns / Variables ***/

SELECT * 
FROM Projet2.dbo.NashvilleHousing

ALTER TABLE Projet2.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

