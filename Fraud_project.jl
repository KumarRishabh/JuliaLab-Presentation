### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 64d04df1-d7b2-431e-a419-f63016eabc99
using DataFrames

# ╔═╡ ce55cf92-1064-4a6d-9e0d-cf7338c04e4c
using Random

# ╔═╡ 0e770be1-4d3d-48c3-8c5f-558f5314a0dc
# Set a random seed for reproducibility (optional)
Random.seed!(42)

# ╔═╡ a1bb457f-4b57-4984-85b6-858fa4d1a1ea
# Define the number of months, providers, patients, and services
n_months = 12

# ╔═╡ 6c8ffe6e-c815-4f55-a544-128b794e9919
n_providers = 50

# ╔═╡ a00c1f65-9222-485e-9673-ad41fb703233
n_patients = 1000

# ╔═╡ 68e8b92e-61c0-4a0f-aa6a-ab597408e9b8
# Define services rendered categories
services_categories = ["Consultation", "Surgery", "Laboratory", "Imaging", "Medication"]

# ╔═╡ f5300dcb-a8ce-477c-8a03-68e9453e17c1
# Define the list of provider IDs for which you want to simulate fraud
fraudulent_providers = [1, 7, 15]

# ╔═╡ c058720e-9ffe-4c32-ab80-bfc035ae56a4
# Define fraud mindsets for each fraudulent provider
fraudulent_provider_mindsets = Dict(
    1 => ["Upcoding", "Laboratory"],
    7 => ["Surgery", "Imaging"],
    15 => ["Upcoding", "Pharmacy Kickbacks"]
)

# ╔═╡ f45d6c68-2c00-4aa6-85bb-0d00c8b13dc9
# Generate random data for each month, provider, patient, and service
data = []

# ╔═╡ 3c538c02-5b5d-43c1-9bff-7a0a8411eba4
for month in 1:n_months
    for provider_id in 1:n_providers
        for patient_id in 1:n_patients
            services_rendered = rand(services_categories)
            claim_amount = rand(100:10000)  # Random claim amount between 100 and 10000
            age_patient = rand(18:99)  # Random age of patient between 18 and 99
            gender_patient = rand(["Male", "Female"])
            race_patient = rand(["White", "Black", "Asian", "Hispanic", "Other"])

            # Categorize age into age groups
            age_group = if age_patient < 65
                "Less than 65"
            elseif age_patient < 75
                "Between 65 and 74"
            elseif age_patient < 85
                "Between 75 and 84"
            else
                "Greater than 84"
            end

            # Check if the current provider is in the list of fraudulent providers
            if provider_id in fraudulent_providers
                # Get the fraud mindsets for the current provider
                provider_mindsets = get(fraudulent_provider_mindsets, provider_id, [])

                # Simulate fraud based on provider's mindsets
                for fraud_type in provider_mindsets
                    claim_amount_modifier = 1.0
                    if fraud_type == "Upcoding"
                        claim_amount_modifier *= 1.5  # Simulate upcoding by increasing the claim amount by 50%
                    elseif fraud_type == "Surgery"
                        claim_amount_modifier *= 2  # Simulate surgery fraud by doubling the claim amount
                    elseif fraud_type == "Laboratory"
                        claim_amount_modifier *= 1.7  # Simulate laboratory fraud by increasing the claim amount by 70%
                    elseif fraud_type == "Imaging"
                        claim_amount_modifier *= 1.3  # Simulate imaging fraud by increasing the claim amount by 30%
                    elseif fraud_type == "Pharmacy Kickbacks"
                        claim_amount_modifier *= 1.8  # Simulate pharmacy kickbacks fraud by increasing the claim amount by 80%
                    end

                    # Append fraud type and modified claim amount to the data
                    push!(data, [month, provider_id, patient_id, services_rendered, claim_amount * claim_amount_modifier, age_group, gender_patient, race_patient, fraud_type])
                end
            else
                # Append normal data for non-fraudulent providers
                push!(data, [month, provider_id, patient_id, services_rendered, claim_amount, age_group, gender_patient, race_patient, "Normal"])
            end
        end
    end
end

# ╔═╡ 0bc67faa-234c-46a3-a2b0-85687cd4a0c6
data[1][1]

# ╔═╡ fdd50e4f-04d1-40ed-87e6-8e657d328ed8
function columns(a_list,j)
	a_list = []
	for i in 1:636000
		push!(a_list,data[i][j])
	end
	return a_list
end

# ╔═╡ 3af85a45-b866-4a07-a1f0-67658975e8cc
columns(empty,4)

# ╔═╡ 1a2c2634-4822-41bb-af9b-5574d48bd682
# Create a DataFrame
df = DataFrame("Month" => columns(empty,1), "Provider_ID" => columns(empty,2), "Patient_ID" => columns(empty,3), "Services_Rendered" => columns(empty,4), "Claim_Amount" => columns(empty,5), "Age_Group" => columns(empty,6), "Gender_Patient" => columns(empty,7), "Race_Patient" => columns(empty,8), "Fraud_Type" => columns(empty,9))


# ╔═╡ 585f9f3b-f567-4cc0-9080-0930f7c5004c
# Print the first few rows of the dataset
first(df, 5)

# ╔═╡ b5245a0f-a311-4baf-ac7c-c202255c3f6b
function bin(df, age, gender, service, provider)
    bin = 0
    for i in 1:nrow(df)
        if df[i, :Age_Group] == age && df[i, :Gender_Patient] == gender && df[i, :Services_Rendered] == service && df[i, :Provider_ID] == provider
            bin += df[i, :Claim_Amount]
        end
    end
    return bin
end


# ╔═╡ 0619a910-8c1a-4c52-8de1-e3fcfc3c8f1e
function sum_bin(df, ages, genders, services, providers)
	bins = []
	for provider in providers
		for service in services
			for gender in genders
				for age in ages
    				push!(bins,sum(bin(df, age, gender, service, provider)))
				end
			end
		end
	end
    return bins
end


# ╔═╡ bdcf22c6-2465-4a93-8e9d-6260228c01c2
age = ["Less than 65", "Between 65 and 74", "Between 75 and 84", "Greater than 84"]

# ╔═╡ e4367bf0-c63f-4bfb-8581-ad5433a834c0
gender = ["Male", "Female"]

# ╔═╡ 8cf9607b-47bb-4c06-a004-0b211e4ea774
service = ["Consultation", "Surgery", "Laboratory", "Imaging", "Medication"]

# ╔═╡ 8458c1a5-f06b-4436-aaf9-176237bae163
provider = collect(1:50)

# ╔═╡ 00a669a7-0db4-4267-83b2-fd9537a04c3a
Y = sum_bin(df,age,gender,service,provider)

# ╔═╡ 2991b55f-e07a-4889-9381-b05e2fc934e8
length(Y)

# ╔═╡ 471eea70-9ccb-4ab0-89b7-11b76be60fa5
# Core Forward Algorithms

# ╔═╡ d92aec3f-ca2f-47b8-a084-2ebd0428a201


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
DataFrames = "~1.6.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Compat]]
deps = ["Dates", "LinearAlgebra", "TOML", "UUIDs"]
git-tree-sha1 = "75bd5b6fc5089df449b5d35fa501c846c9b6549b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.12.0"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "ac67408d9ddf207de5cfa9a97e114352430f01ed"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.16"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╠═64d04df1-d7b2-431e-a419-f63016eabc99
# ╠═ce55cf92-1064-4a6d-9e0d-cf7338c04e4c
# ╠═0e770be1-4d3d-48c3-8c5f-558f5314a0dc
# ╠═a1bb457f-4b57-4984-85b6-858fa4d1a1ea
# ╠═6c8ffe6e-c815-4f55-a544-128b794e9919
# ╠═a00c1f65-9222-485e-9673-ad41fb703233
# ╠═68e8b92e-61c0-4a0f-aa6a-ab597408e9b8
# ╠═f5300dcb-a8ce-477c-8a03-68e9453e17c1
# ╠═c058720e-9ffe-4c32-ab80-bfc035ae56a4
# ╠═f45d6c68-2c00-4aa6-85bb-0d00c8b13dc9
# ╠═3c538c02-5b5d-43c1-9bff-7a0a8411eba4
# ╠═0bc67faa-234c-46a3-a2b0-85687cd4a0c6
# ╠═fdd50e4f-04d1-40ed-87e6-8e657d328ed8
# ╠═3af85a45-b866-4a07-a1f0-67658975e8cc
# ╠═1a2c2634-4822-41bb-af9b-5574d48bd682
# ╠═585f9f3b-f567-4cc0-9080-0930f7c5004c
# ╠═b5245a0f-a311-4baf-ac7c-c202255c3f6b
# ╠═0619a910-8c1a-4c52-8de1-e3fcfc3c8f1e
# ╠═bdcf22c6-2465-4a93-8e9d-6260228c01c2
# ╠═e4367bf0-c63f-4bfb-8581-ad5433a834c0
# ╠═8cf9607b-47bb-4c06-a004-0b211e4ea774
# ╠═8458c1a5-f06b-4436-aaf9-176237bae163
# ╠═00a669a7-0db4-4267-83b2-fd9537a04c3a
# ╠═2991b55f-e07a-4889-9381-b05e2fc934e8
# ╠═471eea70-9ccb-4ab0-89b7-11b76be60fa5
# ╠═d92aec3f-ca2f-47b8-a084-2ebd0428a201
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
