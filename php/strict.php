<?php
// Throw exceptions on all PHP errors/warnings/notices.
function error_to_exception($errno, $errstr, $errfile, $errline, $context)
{
    // If the error is being suppressed with '@', don't throw an exception.
    if (error_reporting() === 0) return;
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
}
set_error_handler('error_to_exception');
