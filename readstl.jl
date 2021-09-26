
##using PyPlot

function stlReadBinary(fileName::String)
    # 
    # STL binary file format
	# Only Grids of tringular elemenents!!!!  
	# Only One solid object per file!!!
    #
 
    # Binary STL: 
    #
    # HEADER:
    # 80 bytes:  Header text
    # 4 bytes:   (int) The number of facets in the STL mesh
    #
    # DATA:
    # 4 bytes:  (float) normal x
    # 4 bytes:  (float) normal y
    # 4 bytes:  (float) normal z
    # 4 bytes:  (float) vertex1 x
    # 4 bytes:  (float) vertex1 y
    # 4 bytes:  (float) vertex1 z
    # 4 bytes:  (float) vertex2 x
    # 4 bytes:  (float) vertex2 y
    # 4 bytes:  (float) vertex2 z
    # 4 bytes:  (float) vertex3 x
    # 4 bytes:  (float) vertex3 y
    # 4 bytes:  (float) vertex3 z
    # 2 bytes:  Padding to make the data for each facet 50-bytes in length
    #   ...and repeat for next facet...
	
	
	arrayVal = zeros(UInt8,80);
  
	fid = open(fileName,"r");
	readbytes!(fid, arrayVal,sizeof(arrayVal))


	header = "";
	for i = 1:80
		symbol = convert(Char,arrayVal[i])
		header = header*symbol;
	end
	println("STL header: ", header); 
	## typically it gives something like this: STLB ATF 2.0.0.9000
	## it can be skipped ... 
	name = "Object";

	Nfacet = read(fid,Int32);
	println("Number of facets: ", Nfacet);

	facetNormals  = zeros(Float32,Nfacet,3)
	facetVertices = zeros(Float32,Nfacet,3*3)

	for i = 1:Nfacet;

		a2byte =  zeros(UInt8,2);

		n1 = read(fid,Float32);
		n2 = read(fid,Float32);
		n3 = read(fid,Float32);
		v1x = read(fid,Float32);
		v1y = read(fid,Float32);
		v1z = read(fid,Float32);
		v2x = read(fid,Float32);
		v2y = read(fid,Float32);
		v2z = read(fid,Float32);
		v3x = read(fid,Float32);
		v3y = read(fid,Float32);
		v3z = read(fid,Float32);
		readbytes!(fid, a2byte ,sizeof(a2byte ))

		facetNormals[i,1] = n1;
		facetNormals[i,2] = n1;
		facetNormals[i,3] = n1;
		
		facetVertices[i,1] =  v1x;
		facetVertices[i,2] =  v1y;
		facetVertices[i,3] =  v1z;
		
		facetVertices[i,4] =  v2x;
		facetVertices[i,5] =  v2y;
		facetVertices[i,6] =  v2z;

		facetVertices[i,7] =  v3x;
		facetVertices[i,8] =  v3y;
		facetVertices[i,9] =  v3z;

		
	end

	close(fid);
  
	# return:
	# object name
	# normals 
	# triangular facet coordinates  
	return name, facetNormals, facetVertices;

end


function stlReadAscii(fileName::String)
    # 
    # STL ascii file format
	# Only Grids of tringular elemenents!!!!  
	# Only One solid object per file!!!
    #
    # solid object_name
	# 
    # facet normal x y z
    #   outer loop
    #     vertex x y z
    #     vertex x y z
    #     vertex x y z
    #   endloop
    # endfacet
    #
    # <Repeat for all facets...>
    #
    # endsolid object_name
	
	data  = readlines(fileName)
	
	display(data)
	
	N = size(data,1);
	
	Nfacets = Int64((N-2)/7);
	
	println("Number of lines in data: ", N)
	println("Number of facets in data: ", Nfacets)
	
	facetNormals  = zeros(Float32,Nfacets,3)
	facetVertices = zeros(Float32,Nfacets,3*3)
	
	line1 = data[1];
	name = "";
	
	# read the STL name
	if (length(line1) >= 7)
        name = line1[7:end];
    else
        name = "Object";
    end
	

	for i = 1:Nfacets,
	
		J = i + 6*(i-1); 
		#display(J)
	
		line_x2 = strip(data[J+1]); ## contains "facet normals"
		line_x3 = strip(data[J+2]); ## contains "outer loop"
		line_x4 = strip(data[J+3]); ## contains "vertex"
		line_x5 = strip(data[J+4]); ## contains "vertex"
		line_x6 = strip(data[J+5]); ## contains "vertex"
		line_x7 = strip(data[J+6]); ## contains "endloop"
		line_x8 = strip(data[J+7]); ## contains "endfacet"
				
		if (contains(line_x2,"facet normal"))
			nstr = split(line_x2); ## array of 5 strings, first two strings are "facet" and "normal", 3,4,5 are numerical values
			#deleteat!(nstr, findall(x->x==" ",nstr))
			#display(nstr[3])
			facetNormals[i,1] = parse(Float32,nstr[3]);
			facetNormals[i,2] = parse(Float32,nstr[4]);
			facetNormals[i,3] = parse(Float32,nstr[5]);
		end
		
		if (contains(line_x4,"vertex"))
			nstr = split(line_x4); ## array of 4 strings, first is "vertex" , 2,3,4 are numerical values
			facetVertices[i,1] = parse(Float32,nstr[2]);
			facetVertices[i,2] = parse(Float32,nstr[3]);
			facetVertices[i,3] = parse(Float32,nstr[4]);
		end
		if (contains(line_x5,"vertex"))
			nstr = split(line_x5); ## array of 4 strings, first is "vertex" , 2,3,4 are numerical values
			facetVertices[i,4] = parse(Float32,nstr[2]);
			facetVertices[i,5] = parse(Float32,nstr[3]);
			facetVertices[i,6] = parse(Float32,nstr[4]);
		end
		if (contains(line_x6,"vertex"))
			nstr = split(line_x6); ## array of 4 strings, first is "vertex" , 2,3,4 are numerical values
			facetVertices[i,7] = parse(Float32,nstr[2]);
			facetVertices[i,8] = parse(Float32,nstr[3]);
			facetVertices[i,9] = parse(Float32,nstr[4]);
		end

		
	end ## end J
	
	# return:
	# object name
	# normals 
	# triangular facet coordinates  
	return name, facetNormals, facetVertices;
	
	
end



function stlGetFormat(fileName::String)
	# check is STL binary or Ascii 
    
	format = "";
	
	if !isfile(fileName)
		println("Cant find file ", fileName);
		return nothing;
	end
	
	fid = open(fileName, "r");
	fidSize = filesize(fileName);
	
	
    if rem(fidSize-84,50) > 0
		
        format = "ascii";
    else
	
        # Files with a size of 84+(50*n), might be either ascii or binary...
        
        # ASCII file: and the first word must be 'solid'
		# Binary file: the first 80 characters contains the header.
						
		
		s_buff80 = "";
		e_buff80 = "";
		seek(fid,0); # goto the beginning of the file 
		for i = 1:80 # Read first 80 characters of the file.
			sym = read(fid,Char);
			s_buff80 = s_buff80 * sym;
		end
		
		# Reading the last 80 characters of the file.
		# ASCII file: the data is ended  with 'endsolid <object_name>'
		# I guess the scond condition can be skipped (?)
		
		seek(fid,position(seekend(fid))-80); 
        
        	
		while !eof(fid) #for i = 1:80
			sym = read(fid,Char);
			e_buff80 = e_buff80 * sym;
		end
	
		println(s_buff80)
		println(e_buff80)
        
		#isSolid = contains(s_buff80,"solid")
		#isEndSolid = contains(e_buff80,"endsolid")
		
		isSolid = occursin(s_buff80,"solid")
		isEndSolid = occursin(e_buff80,"endsolid")
				
        if isSolid & isEndSolid
            format = "ascii";
        else
            format = "binary";
        end
		
    end
	
	close(fid);
	return format;
	
end




function stlRead(fileName::String)

	# Only Grids of tringular elemenents!!!!  
	# Only One solid object per file!!!
	
    format = stlGetFormat(fileName);
	
    if format == "ascii"
        return stlReadAscii(fileName);
    elseif format == "binary"
        return stlReadBinary(fileName);
	else
		println("stl format is not defined or/and may be corrupted ... ")
		
		return nothing; 
    end
	
end


function plotStl(fileName::String)


	name, facetNormals, facetVertices = stlRead(fileName);
	
	display(name)
	display(facetNormals)
	display(facetVertices)
	

	Nt = size(facetNormals,1) # define the number of triangles 
	p = zeros(Float32, Nt*3, 3); # number of points is Nt*3
	triangles = zeros(Int64, Nt, 3);
	
	# make structures for triangles and points 
	# for MatPlotLib library
	
	for i = 1:Nt
		
		J = i + 2*(i-1);
	
		triangles[i,1] = J+0-1; ## this if for MatPLotLib tri_surf: first triangle starts from 0 !!!!
		triangles[i,2] = J+1-1;
		triangles[i,3] = J+2-1;
		
		p[J,1] = facetVertices[i,1]
		p[J,2] = facetVertices[i,2]
		p[J,3] = facetVertices[i,3]
		
		p[J+1,1] = facetVertices[i,4]
		p[J+1,2] = facetVertices[i,5]
		p[J+1,3] = facetVertices[i,6]
		
		p[J+2,1] = facetVertices[i,7]
		p[J+2,2] = facetVertices[i,8]
		p[J+2,3] = facetVertices[i,9]
		
	end
	

	#display(triangles)
	#display(p)


	## alternative 
	## using FileIO
	## using GLMakie
	## korpus  = load(assetpath("korpus.stl"))
		
	#azimuth = 0.0*pi, elevation = 0.0*pi - y-z plane front
	#azimuth = 0.5*pi, elevation = 0.5*pi - x-y plane top 
	#azimuth = 0.5*pi, elevation = 0.0*pi - x-z plane lateral
	
	
	#fig, ax, _ = mesh(p[:,1], p[:,2], p[:,3], 	axis=(; type=Axis3, azimuth = 0.0*pi, elevation = 0.0*pi, aspect = :data, viewmode = :fit ))
    #fig
	
	mesh(p[:,1], p[:,2], p[:,3]) 	

end
