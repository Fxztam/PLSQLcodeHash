# PLSQLcodeHash
## Motivation

Changes to PL / SQL programs can be recognized using the source code timestamp in the repository.
However, it is not clear whether effective PL / SQL code or only comments or white spaces were changed.

PLSQLcodeHash determines the hash code of the effective PL / SQL code without white spaces and comments, so that proof of real code changes is possible by means of hash code comparison.

The program was deliberately programmed simply and transparently with GOTO’s in order to enable possible extensions without side effects.

