SVMREPOS=/media/frank/svn/perl
path=/mirror/parrot
url=http://svn.perl.org/parrot

#svm init $path $url
# svm sync path x. artinya dari changeset 1-x itu di-flatten
svm sync $path 0

# merge back changes in local branch
# svn cp file://$SVMREPOS$path file://$SVMREPOS/svn-local
# make some changes and then merge back to source repository
# svm mergeback $path svn-local
