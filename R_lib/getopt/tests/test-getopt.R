context("Testing getopt")
test_that("getopt works as expected", {
    spec = matrix(c(
      'verbose', 'v', 2, "integer",
      'help'   , 'h', 0, "logical",
      'dummy1' , 'd', 0, "logical",
      'dummy2' , 'e', 2, "logical",
      'count'  , 'c', 1, "integer",
      'mean'   , 'm', 1, "double",
      'sd'     , 's', 1, "double",
      'output' , 'O', 1, "character"
    ), ncol=4, byrow=TRUE);
    expect_equal(sort_list(getopt(spec, c('-c', '-1', '-m', '-1.2'))),
                    sort_list(list(ARGS=character(0), count=-1, mean=-1.2)));
    expect_equal(sort_list(getopt(spec, c('-v', '-m', '3'))),
                    sort_list(list(ARGS=character(0), verbose=1, mean=3)));
    expect_equal(sort_list(getopt(spec, c('-m', '3', '-v'))),
            sort_list(list(ARGS=character(0), mean=3, verbose=1)));
    expect_equal(sort_list(getopt(spec, c('-m', '3', '-v', '2', '-v'))),
            sort_list(list(ARGS=character(0), mean=3, verbose=1)));
    expect_equal(sort_list(getopt(spec, c('-O', '-', '-m', '3'))),
            sort_list(list(ARGS=character(0), output="-", mean=3)));
    expect_equal(sort_list(getopt(spec, c('-O', '-', '-m', '3'))),
            sort_list(getopt(spec, c('-m', '3', '-O', '-'))));
    expect_equal(sort_list(getopt(spec, c('-de'))), 
            sort_list(getopt(spec, c('-ed'))));
    expect_equal(sort_list(getopt(spec, c('-de'))), 
            sort_list(list(ARGS=character(0), dummy1=TRUE, dummy2=TRUE)));
    expect_equal(sort_list(getopt(spec, c('-de', '1'))),
            sort_list(list(ARGS=character(0), dummy1=TRUE, dummy2=NA)));
    expect_equal(sort_list(getopt(spec, c('--verbose'))),
            sort_list(list(ARGS=character(0), verbose=1)));
    expect_equal(sort_list(getopt(spec, c('--verbose', '--help'))),
            sort_list(list(ARGS=character(0), verbose=1, help=TRUE)));
    expect_equal(sort_list(getopt(spec, c('--verbose', '--mean', '5'))),
            sort_list(list(ARGS=character(0), verbose=1, mean=5)));
    expect_equal(sort_list(getopt(spec, c('--mean=5'))), 
            sort_list(list(ARGS=character(0), mean=5)));
    expect_equal(sort_list(getopt(spec, c('--verbose', '--mean=5', '--sd', '5'))),
            sort_list(list(ARGS=character(0), verbose=1, mean=5, sd=5)));
    expect_equal(sort_list(getopt(spec, c('--verbose', '--mean=5', '--sd', '5'))),
            sort_list(getopt(spec, c('--mean=5', '--sd', '5', '--verbose'))));

    spec = c(
      'date'     , 'd', 1, "character",
      'help'     , 'h', 0, "logical",
      'getdata'  , 'g', 0, "logical",
      'market'   , 'm', 1, "character",
      'threshold', 't', 1, "double"
    );
    spec2 <- matrix(spec, ncol=4, byrow=TRUE)
    # should give warning is spec is not matrix
    expect_that(getopt(spec, c('--date','20080421','--market','YM','--getdata')), gives_warning());
    expect_equal(sort_list(getopt(spec2, c('--date','20080421','--market','YM','--getdata'))),
            sort_list(list(ARGS=character(0), date='20080421', market='YM', getdata=TRUE)))
    expect_equal(sort_list(getopt(spec2, c('--date','20080421','--market','YM','--getdata'))),
            sort_list(getopt(spec2, c('--date','20080421','--getdata','--market','YM'))));
    expect_that(getopt(spec2, c('--date','20080421','--getdata','--market','YM'),debug=TRUE), 
            prints_text("processing "));
    expect_that(print(getopt(spec2, c('--date','20080421','--getdata','--market','YM'),usage=TRUE)),
            prints_text("Usage: "));
})
test_that("numeric is cast to double", {
    # Feature reported upstream (optparse) by Miroslav Posta
    spec = matrix(c("count", "c", 1, "integer"), ncol=4, byrow=TRUE)
    getopt(spec, c("-c", "-55"))
    spec = matrix(c("count", "c", 1, "numeric"), ncol=4, byrow=TRUE)
    getopt(spec, c("-c", "-55.0"))
})

test_that("don't throw error if multiple matches match one argument fully", {
    # test if partial name matches fully, 
    # still throw error if multiple matches and doesn't match both fully
    # feature request from Jonas Zimmermann
    spec = matrix(c(
      'foo'      , 'f', 0, "logical",
      'foobar'   , 'b', 0, "logical",
      'biz'      , 'z', 0, "logical"
      ), ncol=4, byrow=TRUE)
    expect_that(getopt(spec, c('--fo')), throws_error())
    expect_equal(getopt(spec, c('--foo')), sort_list(list(ARGS=character(0), foo=TRUE)))
})

context("Test sort_list")
test_that("sort_list works as expected", {
    expect_equal(sort_list(list(a = 3, b = 2)), sort_list(list(b = 2, a = 3)))
    expect_false(identical(sort_list(list(b = 3, a = 2)), list(b = 3, a = 2)))
})
