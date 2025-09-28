//
//  ArticleFetcher.swift
//  petros-app
//
//  Created by Connor York on 9/25/25.
//

import Foundation

class ArticleFetcher {
    static let dummyBody = "On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains."
    
    static func fetchFoundationNightArticles() -> [Article] {
        return [
            Article(
                title: "IN THE WORLD BUT NOT OF THE WORLD",
                subtitle: "Foundation Night: October",
                description: "Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum",
                body: dummyBody
                

            ),
            Article(
                title: "FAITH, HOPE, AND LOVE",
                subtitle: "Foundation Night: September",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
                body: dummyBody
                

            ),
            Article(
                title: "WALKING IN TRUTH",
                subtitle: "Foundation Night: August",
                description: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                body: dummyBody
            ),
            Article(
                title: "THE POWER OF PRAYER",
                subtitle: "Foundation Night: July",
                description: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
                body: dummyBody
            ),
            Article(
                title: "GRACE AND MERCY",
                subtitle: "Foundation Night: June",
                description: "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet.",
                body: dummyBody
            ),
            Article(
                title: "SERVING WITH JOY",
                subtitle: "Foundation Night: May",
                description: "Consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.",
                body: dummyBody
            )
        ]
    }
}
