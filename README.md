# PLSQLcodeHash (get_CodeHash4Cmp)

## Motivation

Changes to PL/SQL programs can be recognized using the source code timestamp in the repository.

However, it is not clear whether effective PL / SQL code or only comments, white spaces or lower/upper case tokens were changed.

The function _get_CodeHash4Cmp_ determines the hash code of the effective PL/SQL code without white spaces, comments or changed lower/upper case tokens, so that proof of real code changes is possible by means of hash code comparison.

The program was deliberately programmed simply and transparently with GOTO’s in order to enable possible extensions without side effects.

## Quick Start

After saving the *get_CodeHash4Cmp* function, the following application steps are possible:

```
select get_CodeHash4Cmp('<stored-code-name>') from dual;
```

Then you will get the SHA512 code hash so you can save it for later comparison:

```
select get_CodeHash4Cmp('<stored-code-name>', '<PLSQL-code-hash-to-compare>') from dual;
```

### Example:

- Step 1: Save the example procedure _prc_example_ into the database:

```sql
create or replace procedure prc_example(p_x VARCHAR2) is
  /*
    This is a PL/SQL code demo for code hashing.
    F.Matz : 2020-10-19
    --
  */
  l_y NUMBER;
begin
  -- get PI --
  l_y := acos(-1);
  dbms_output.put_line(l_y);
end prc_example;
```

- Step 2: Get the PL/SQL code hash from this *prc_example* and store it:

```
select get_codehash4cmp('PRC_EXAMPLE') from dual;

CF83E1357EEFB8BDF1542850D66D8007D620E4050B5715DC83F4A921D36CE9CE47D0D13C5D85F2B0FF8318D2877EEC2F63B931BD47417A81A538327AF927DA3E

```

- Step 3: Save the changed example procedure _prc_example_changed into the database:

```
create or replace PROCEDURE Prc_Example(p_x VARCHAR2) IS

  /*
    This is a PL/SQL code demo for code hashing.
    F.Matz : 2020-10-19
    -- comment changed ! 
  */
  
  l_y NUMBER;
  
BEGIN
  
  -- get PI --
  -- new comment ... --
  l_y := Acos(-1);
  dbms_output.put_line(l_y);
  
END Prc_Example;
```

- Step 4:  Compare the actual PL/SQL code hash with the stored:

```
select get_codehash4cmp('PRC_EXAMPLE_CHANGED', 'CF83E1357EEFB8BDF1542850D66D8007D620E4050B5715DC83F4A921D36CE9CE47D0D13C5D85F2B0FF8318D2877EEC2F63B931BD47417A81A538327AF927DA3E') from dual;

=> PRC_EXAMPLE : OK
```

That's all.
