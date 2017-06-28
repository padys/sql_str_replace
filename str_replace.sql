CREATE DEFINER=`root`@`localhost` FUNCTION `str_replace`(string_search TEXT CHARSET utf8, string_replace TEXT CHARSET utf8, string_subject TEXT CHARSET utf8) RETURNS text CHARSET utf8
BEGIN

-- string_search/string_replace items separator
DECLARE ws TEXT CHARSET utf8 default ',';
-- ghost letter - one char that can't exist in string_subject
DECLARE ghost TEXT CHARSET utf8 default '\0';

-- string in which I will search items and replace them with ghosts
DECLARE string_test TEXT CHARSET utf8 default '';
-- result string
DECLARE string_output TEXT CHARSET utf8 default '';

-- how many items to search
DECLARE string_search_items INT DEFAULT 0;
-- how many items to replace
DECLARE string_replace_items INT DEFAULT 0;
-- iterator
DECLARE iterator INT DEFAULT 0;
-- position of replacement 
DECLARE pos INT DEFAULT 0;

-- one item to search
DECLARE replace_from TEXT CHARSET utf8 default '';
-- corresponding item to replace
DECLARE replace_to TEXT CHARSET utf8 default '';

-- length of item to search
DECLARE replace_from_length INT DEFAULT 0;
-- replacement in string_test
DECLARE replace_to_ghost TEXT CHARSET utf8 default '';

SET string_test = string_subject;
SET string_output = string_subject;

SET string_search_items = char_length(string_search)-char_length(replace(string_search, ws, ''));
SET string_replace_items = char_length(string_replace)-char_length(replace(string_replace, ws, ''));

-- lengths of string_search and string_replace have to fit together 
IF string_search_items > string_replace_items THEN
	SET string_replace = concat(string_replace, REPEAT(ws, string_search_items-string_replace_items));
END IF;

-- iteration over string_search items
iteration: LOOP 

	IF iterator > string_search_items THEN
		LEAVE iteration;
	END IF;
    
	SET iterator = iterator + 1;
    
    SET replace_from = substring_index(substring_index(string_search, ws, iterator), ws, -1);
	SET replace_to = substring_index(substring_index(string_replace, ws, iterator), ws, -1);
    SET replace_from_length = char_length(replace_from);
    SET replace_to_ghost = repeat(ghost, char_length(replace_to));
    
    replacing: LOOP 
		SET pos = LOCATE(replace_from, string_test);
        IF pos = 0 THEN
			LEAVE replacing;
		END IF;

		SET string_output = insert(string_output, pos, replace_from_length, replace_to);
		SET string_test = insert(string_test, pos, replace_from_length, replace_to_ghost);
		
	END LOOP replacing;
    
END LOOP iteration;

RETURN string_output;
END
