Select*
From HousingPortfolioProject..NashvilleHousing

--Convert SaleDate Col format
Select Convert(Date, SaleDate) SaleDateConverted  
From HousingPortfolioProject..NashvilleHousing

--Add new col with updated Col format
Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted=Convert(Date,SaleDate)

Select SaleDateConverted 
From NashvilleHousing

---------------------------------------------

--Populate Property  Address data
Select PropertyAddress
From HousingPortfolioProject..NashvilleHousing
Where PropertyAddress IS NULL

Select *
From HousingPortfolioProject..NashvilleHousing
Where PropertyAddress IS NULL

Select *
From HousingPortfolioProject..NashvilleHousing
--Step 1
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From HousingPortfolioProject..NashvilleHousing a
JOIN HousingPortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress is null

--Step2
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull(a.PropertyAddress,b.PropertyAddress)
From HousingPortfolioProject..NashvilleHousing a
JOIN HousingPortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress is null

--Step 3 Updating orgnl table

Update a
Set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingPortfolioProject..NashvilleHousing a
JOIN HousingPortfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress is null

Select PropertyAddress
From HousingPortfolioProject..NashvilleHousing
Where PropertyAddress IS NULL

--Breaking address in individual columns address, city, state
Select PropertyAddress
From HousingPortfolioProject..NashvilleHousing

Select
Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress)) as City
From HousingPortfolioProject..NashvilleHousing

--Adding PropertySplitAddress in original table
Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress=Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1)

--Adding PropertySplitCity in original table
Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity=Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity
From NashvilleHousing

--Splitting Owner Address
Select OwnerAddress
From HousingPortfolioProject..NashvilleHousing
--Using ParseName
Select
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
From HousingPortfolioProject..NashvilleHousing

--Adding OwnerSplitAddress in original table
Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress=Parsename(Replace(OwnerAddress,',','.'),3)

--Adding OwnerSplitCity in original table
Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity=Parsename(Replace(OwnerAddress,',','.'),2)

--Adding OwnerSplitState in original table
Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState=Parsename(Replace(OwnerAddress,',','.'),1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldasVacant
From NashvilleHousing

Select Distinct (SoldasVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldasVacant,
Case When SoldasVacant='Y' Then 'Yes'
	 When SoldasVacant='N' Then 'No'
	 Else SoldasVacant
	 End
From HousingPortfolioProject..NashvilleHousing

--Updating Table
Update NashvilleHousing
SET SoldAsVacant=Case When SoldasVacant='Y' Then 'Yes'
	 When SoldasVacant='N' Then 'No'
	 Else SoldasVacant
	 End

Select Distinct (SoldasVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

--Delete Duplicates from table

--Step1: See Duplicates
Select*,
Row_Number()OVER(
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) row_num

From HousingPortfolioProject..NashvilleHousing
Order by ParcelID

--Step2: Defining CTE, as Where row_num>1 can't be used with above query, as row_num is alias

With RowNumCTE as(
Select*,
Row_Number()OVER(
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) row_num

From HousingPortfolioProject..NashvilleHousing
)

Select*
From RowNumCTE

--Step3: See entries where row_num>1 using CTE

With RowNumCTE as(
Select*,
Row_Number()OVER(
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) row_num

From HousingPortfolioProject..NashvilleHousing
)

Select*
From RowNumCTE
Where Row_num>1
Order by PropertyAddress

--Delete Duplicate Entries from RowNumCTE
With RowNumCTE as(
Select*,
Row_Number()OVER(
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) row_num

From HousingPortfolioProject..NashvilleHousing
)

Delete
From RowNumCTE
Where Row_num>1
--Deleted from RowNumCTE
With RowNumCTE as(
Select*,
Row_Number()OVER(
	Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) row_num

From HousingPortfolioProject..NashvilleHousing
)
Select*
From RowNumCTE
Where Row_num>1
Order by PropertyAddress

--Delete Unused Columns

Select*
From HousingPortfolioProject..NashvilleHousing
--PropertyAddress, TaxDistrict, OwnerAddress cols are useless, as they are in SplitAddress columns 

Alter Table HousingPortfolioProject..NashvilleHousing
Drop Column PropertyAddress, TaxDistrict, OwnerAddress



