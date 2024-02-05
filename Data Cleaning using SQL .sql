-- -- Data Cleaning in SQL
select * from nashville_housedataset;

-- -- Populate Property Address Data
select * from nashville_housedataset where propertyaddress is null;
-- -- we are going to use parcelid to populate property address because it appears
-- -- to be same, hence we are going to use a SELF JOIN

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,
       COALESCE(a.propertyaddress, b.propertyaddress) AS merged_address
FROM nashville_housedataset a
JOIN nashville_housedataset b ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;
-- -- Merged_address (alias), is the result of using b.property address to
-- -- fill the null values in a.property address
-- -- going to use an update function, to update the table

UPDATE nashville_housedataset a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housedataset b
WHERE a.propertyaddress is null;

select * from nashville_housedataset where propertyaddress is null;
-- -- used this command to crosscheck if the empty values have been
-- -- updated

-- -- Breaking Out Address Into Individual Columns
select propertyaddress from nashville_housedataset;
-- -- going to use a substring , character index p.s in postgres we use position
-- -- instead of characterindex to achieve the same result
select 
substring(propertyaddress,1, POSITION(',' in propertyaddress)-1) as address
,substring(propertyaddress,
POSITION(',' in propertyaddress)+1) as address
from nashville_housedataset;
-- -- we can't seperate two values from one column ,
-- -- hence there's a need to create two other column

Alter table nashville_housedataset
Add Propertyaddresssplit varchar(80);

update nashville_housedataset
set propertyaddresssplit =substring(propertyaddress,1, POSITION(',' in propertyaddress)-1);

Alter table nashville_housedataset
Add Propertycitysplit varchar(80);

update nashville_housedataset
set propertycitysplit =substring(propertyaddress,
POSITION(',' in propertyaddress)+1); 
-- successfully created the columns and split the address into city and address

-- -- Splitting Owner Address
select owneraddress from nashville_housedataset;


SELECT
    owneraddress,
    TRIM(BOTH ' ' FROM SPLIT_PART(owneraddress, ',', 1)) AS street,
    TRIM(BOTH ' ' FROM SPLIT_PART(owneraddress, ',', 2)) AS city,
    TRIM(BOTH ' ' FROM SPLIT_PART(owneraddress, ',', 3)) AS state
FROM
    nashville_housedataset;
	
ALTER TABLE nashville_housedataset
ADD COLUMN ownersplitaddress VARCHAR(100);


update nashville_housedataset
set ownersplitaddress =TRIM(BOTH ' ' FROM SPLIT_PART(owneraddress, ',', 1));

ALTER TABLE nashville_housedataset
ADD COLUMN ownersplitcity VARCHAR(100);

update nashville_housedataset
set ownersplitcity =TRIM(BOTH ' ' FROM SPLIT_PART(owneraddress, ',', 2));


ALTER TABLE nashville_housedataset
ADD COLUMN ownersplitstate VARCHAR(100);

update nashville_housedataset
set ownersplitstate=TRIM(BOTH ' ' FROM SPLIT_PART(owneraddress, ',', 3));

select * from nashville_housedataset;

-- Change Y to Yes and N to No on Soldasvacant
select distinct(soldasvacant),count(soldasvacant)
from nashville_housedataset
group by soldasvacant
order by 2;
-- since the count of null values in this column is 0, it'll be deleted
Delete from nashville_housedataset
where soldasvacant is null;

-- used a case statement to chnage from Y to yes and N to No
select soldasvacant
,case when soldasvacant ='Y' then 'Yes'
      when soldasvacant ='N' then 'No'
	  Else soldasvacant
	  End
from nashville_housedataset;

-- Successfully updated the column with the right data
update nashville_housedataset
set soldasvacant=case when soldasvacant ='Y' then 'Yes'
      when soldasvacant ='N' then 'No'
	  Else soldasvacant
	  End;
	  
-- Remove Duplicates
WITH DuplicateCTE AS (
    SELECT *,
	   Row_number() over(partition by
        ParcelId,
        PropertyAddress,
        SalePrice,
        SaleDate,
        Legalreference
	    order by 
	       uniqueid
           ) row_num	

       from nashville_housedataset)
Select *
FROM DuplicateCTE
WHERE row_num > 1;
order by propertyaddress;

WITH DuplicateCTE AS (
    SELECT *,
	   ROW_NUMBER() OVER (PARTITION BY ParcelId, PropertyAddress, SalePrice, SaleDate, Legalreference ORDER BY uniqueid) AS row_num
    FROM nashville_housedataset
)
DELETE FROM nashville_housedataset
USING DuplicateCTE
WHERE nashville_housedataset.uniqueid = DuplicateCTE.uniqueid AND DuplicateCTE.row_num > 1;

-- Delete Unused Columns
select * from nashville_housedataset;

ALTER TABLE nashville_housedataset
DROP COLUMN IF EXISTS Owneraddress CASCADE,
DROP COLUMN IF EXISTS Taxdistrict CASCADE,
DROP COLUMN IF EXISTS propertyaddress CASCADE,
DROP COLUMN IF EXISTS saledate CASCADE;
