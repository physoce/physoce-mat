NDBC Scripts - C. Ryan Manzer

These are a series of functions all designed around gathering and organizing data
from NDBC Data buoys.  The main function is NDBCReader.m and it calls other 
functions as necessary.  It is currently only set up to gather the standard
meteorological data but I hope I have commented my code enough that it should
be relatively easy to modify.

**NDBCReader   The stationID field can now be characters which should allow users to enter 
	       non buoy station identifiers.  Also I've added code that removes fields 
	       where all the data present are bad data flags.  Station Data (location, water
	       depth, etc.) will also be collected and included in the structure output.
