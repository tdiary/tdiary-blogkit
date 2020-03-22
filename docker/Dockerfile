FROM tdiary/tdiary:latest
LABEL maintainer "@tdtds <t@tdtds.jp>"

WORKDIR /usr/src/app
RUN echo 'gem "tdiary-blogkit"' >> Gemfile.local; \
    bundle --path=vendor/bundle --without=development:test --jobs=4 --retry=3; \
    sed -i "s/@style.*$/@style = 'BlogWiki'/" tdiary.conf; \
    sed -i "s/@theme.*$/@theme = 'online\/blog'/" tdiary.conf; \
    sed -i 's/recent_list.rb/recent_list.rb\nblog_style.rb\nblog_category.rb\ntheme_online.rb/' tdiary.conf
