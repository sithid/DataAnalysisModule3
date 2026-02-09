-- Query table structure for SQL Murder Mystery
SELECT
  name
FROM sqlite_master
WHERE type = 'table'

-- Not sure where to start so lets look at the interview table
SELECT
  *
FROM interview;

-- Output is disgusting, bunch of random stuff atm.  Need to find a better way to explore the data.
-- Lets join the interview transcripts to the person table so we can atleast associate a name with the id
-- and transcripts.

SELECT
  person.id,
  person.name,
  interview.transcript
FROM person
LEFT JOIN interview ON person.id = interview.person_id
WHERE interview.transcript IS NOT NULL;

-- Still isnt very helpful.  Lets look at the crime reports.
-- Specifics:
--    Type: Murder
--    Date: Jan.15, 2018 (20180115)
--    City: SQL City
SELECT
  *
FROM crime_scene_report
WHERE date = '20180115'
AND type = 'murder'
AND city = 'SQL City';

-- Security footage shows that there were 2 witnesses.
-- The first witness lives at the last house on "Northwestern Dr".
-- The second witness, named Annabel, lives somewhere on "Franklin Ave"
-- Witness 1: Unknown, 'Northwestern Dr'
-- They live at the last house on Northwestern Dr, so that should be the
-- number at the top of the list if we order by desc.
SELECT *
FROM person
WHERE
    person.address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC;


-- Witness 2: Annabel, 'Franklin Ave'
SELECT
  *
FROM person
WHERE person.address_street_name = 'Franklin Ave'
AND person_name LIKE '%Annabel%'
GROUP BY person_id, person_name, street_name;

-- Now we atleast have witness information.  From here we can use the witness person ids to investigate further.
-- Witeness 1: 16371
-- Witeness 2: 14887
SELECT
  person.id,
  person.name,
  interview.transcript
FROM person
JOIN interview ON person.id = interview.person_id
WHERE person_id = 16371
OR person_id = 14887;

-- Witness 1:
--   I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.
-- Witness 2:
--   I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. 
--   The membership number on the bag started with "48Z". Only gold members have those bags. 
--   The man got into a car with a plate that included "H42W".

-- Data inferred from witness reports:
--   The murderer is a man, identified from the gym on January 9th, 2018 (20180109).
--   The murderer is a gym member, most likely a gold gym member.
--   The murderer's gym membership number starts with '48Z'.
--   The murderer's car has a license plate that includes "H42W".

SELECT
  person.id,
  person.name,
  get_fit_now_check_in.membership_id,
  get_fit_now_check_in.check_in_date,
  get_fit_now_check_in.check_in_time,
  get_fit_now_check_in.check_out_time
FROM person
JOIN get_fit_now_member ON person.id = get_fit_now_member.person_id
JOIN get_fit_now_check_in ON get_fit_now_member.id = get_fit_now_check_in.membership_id
WHERE get_fit_now_check_in.membership_id LIKE '48Z%'
AND get_fit_now_check_in.check_in_date = '20180109';

-- Two suspects so far
-- Suspect 1: Joe Germuska
-- Suspect 2: Jeremy Bowers

SELECT
  *
FROM person
WHERE name = 'Joe Germuska'
OR name = 'Jeremy Bowers';

-- Jeremy bowers says he was hired by a woman with alot of money!
-- I was hired by a woman with a lot of money. 
-- I don't know her name but I know she's around 5'5" (65") or 5'7" (67").
-- She has red hair and she drives a Tesla Model S.
-- I know that she attended the SQL Symphony Concert 3 times in December 2017.

-- This should give us a ton of info about all of the women who attended events in december of 2017.
-- We can use this information to try to find the woman who hired Jeremy Bowers.
SELECT
  person.id,
  person.name,
  person.ssn,
  drivers_license.age AS age,
  drivers_license.height AS height,
  drivers_license.eye_color AS eye_color,
  drivers_license.hair_color AS hair_color,
  drivers_license.gender AS gender,
  facebook_event_checkin.event_id AS event_id,
  facebook_event_checkin.date AS event_date,
  facebook_event_checkin.event_name as event_name,
  COUNT(*) AS entry_count
FROM person
JOIN facebook_event_checkin ON person.id = facebook_event_checkin.person_id
JOIN drivers_license ON person.license_id = drivers_license.id
WHERE gender = 'female' AND event_date LIKE '201712%'
GROUP BY person.name
HAVING COUNT(*) >= 3
ORDER BY entry_count DESC;

-- This query returns 2 results, but only one went to the sql symphony concert 3 times in december of 2017.  
-- That person is named "Miranda Priestly".

SELECT
  *
FROM person
JOIN drivers_license ON person.license_id = drivers_license.id
WHERE person.name = 'Miranda Priestly';

-- Lets get income info
SELECT
  person.id,
  person.name,
  income.ssn,
  income.annual_income
FROM person
JOIN income ON person.ssn = income.ssn
WHERE person.name = 'Miranda Priestly';