module Jekyll
  class AuthorPageGenerator < Generator
    safe true

    def generate(site)
      if site.layouts.key? 'contributor_index'
        dir = 'hall-of-fame'

        # pre-calculating this hash saves about 4.9 seconds off the previous
        # build time of 5 seconds.
        tutorials_by_author = Hash.new { |hash, key| hash[key] = [] }
        slides_by_author = Hash.new { |hash, key| hash[key] = [] }
        has_philosophy = Hash.new { false }

        site.pages.each {|t|
          # TUtorials
          if t['layout'] == 'tutorial_hands_on'
            t['contributors'].each{|c| tutorials_by_author[c].push(t) }
          end

          # Slides
          if ! ['base_slides', 'introduction_slides', 'tutorial_slides'].index(t['layout']).nil?
            t['contributors'].each{|c| slides_by_author[c].push(t) }
          end

          # Philosophies
          if t['layout'] == 'training_philosophy'
            has_philosophy[t['username']] = true
          end
        }

        site.data['contributors'].each_key do |contributor|
          # Using PageWithoutAFile instead of a custom class which reads files
          # from disk each time, saves some time, but it is unclear how much
          # due to how the previous was accounted. But assuming 0.040s per page * 193 should be about 8 seconds.
          page2 = PageWithoutAFile.new(site, "", File.join(dir, contributor), "index2.html")
          page2.content = nil
          name = site.data['contributors'][contributor].fetch('name', contributor)

          # Their tutorials
          page2.data["contributor"] = contributor
          page2.data['personname'] = name
          page2.data['title'] = "GTN Contributor: #{name}"
          page2.data["layout"] = "contributor_index"
          page2.data["tutorials"] = tutorials_by_author[contributor]
          page2.data["slides"] = slides_by_author[contributor]
          page2.data["has_philosophy"] = has_philosophy[contributor]
          site.pages << page2
        end
      end
    end
  end
end
