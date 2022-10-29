import SwiftUI

struct MFPInfoSheet: View {
    
    var body: some View {
        NavigationView {
            form
                .navigationTitle("MyFitnessPal Foods")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var form: some View {
        Form {
            
            
            Section {
                Text("""
Use this feature to pre-fill the form with a food from [MyFitnessPal](https://www.myfitnesspal.com).
""")
            }
            
            
            Section("How it works") {
                Text("""
This works by loading the search results on our servers and providing you with the raw data so you don't have to type it out yourself.
""")
                .listRowSeparator(.hidden)
                .foregroundColor(.secondary)
                Text("""
The search is considerably slow as the speed is throttled on their end. **A quicker option** might be to take a screenshot of the food in their app and [use our image scanner to fill in the data](linkwithinapp.com) instead.
""")
                .listRowSeparator(.hidden)
                .foregroundColor(.secondary)
            }
            
            
            Section("Submission to the Public Database") {
                Text("""
We will not verify foods that are solely based on their data, [as MyFitnessPal themselves do not guarantee the information to be accurate](https://support.myfitnesspal.com/hc/en-us/articles/360032273292-What-does-the-check-mark-mean-).
""")
                .listRowSeparator(.hidden)
                .foregroundColor(.secondary)
                Text("""
**If you would like the food to be verified into the public database** [(and generate subscription points)](google.com), you would still need to provide either:
""")
                .listRowSeparator(.hidden)
                .foregroundColor(.primary)
                HStack(alignment: .top) {
                    Text("•")
                    Text("a **photo** of the nutrition label")
                }
                .listRowSeparator(.hidden)
                .foregroundColor(.primary)
                HStack(alignment: .top) {
                    Text("•")
                    Text("a **link** to a verifiable source (such as the supplier's website)")
                }
                .listRowSeparator(.hidden)
                .foregroundColor(.primary)
            }
            
            
            Section("Disclaimer") {
                Text("""
We are in no way affiliated with MyFitnessPal, and do not claim ownership over any of the data they provide.
""")
                .italic()
                .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
}
