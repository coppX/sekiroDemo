using System.Globalization;
using System.Text;
using SoulsFormats;

if (args.Length >= 2 && args[0].Equals("--inspect", StringComparison.OrdinalIgnoreCase))
{
    var inspectPath = Path.GetFullPath(args[1]);
    InspectPath(inspectPath, false);
    return 0;
}

if (args.Length >= 2 && args[0].Equals("--inspect-all", StringComparison.OrdinalIgnoreCase))
{
    var inspectPath = Path.GetFullPath(args[1]);
    InspectPath(inspectPath, true);
    return 0;
}

if (args.Length < 2)
{
    Console.Error.WriteLine("Usage: SekiroFlverObjExporter <input.flver> <output.obj>");
    Console.Error.WriteLine("       SekiroFlverObjExporter --inspect <input.flver|input.bnd|input.dcx>");
    Console.Error.WriteLine("       SekiroFlverObjExporter --inspect-all <input.flver|input.bnd|input.dcx>");
    return 1;
}

var inputPath = Path.GetFullPath(args[0]);
var outputObjPath = Path.GetFullPath(args[1]);
var outputDirectory = Path.GetDirectoryName(outputObjPath)!;
Directory.CreateDirectory(outputDirectory);

var flver = SoulsFile<FLVER2>.Read(inputPath);
var outputName = Path.GetFileNameWithoutExtension(outputObjPath);
var outputMtlName = outputName + ".mtl";
var outputMtlPath = Path.Combine(outputDirectory, outputMtlName);

var invariant = CultureInfo.InvariantCulture;
var obj = new StringBuilder();
var mtl = new StringBuilder();
var vertexOffset = 1;
var totalVertices = 0;
var totalTriangles = 0;
var writtenMaterials = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

obj.AppendLine("# Exported from Sekiro FLVER2");
obj.AppendLine($"mtllib {outputMtlName}");

for (var meshIndex = 0; meshIndex < flver.Meshes.Count; meshIndex++)
{
    var mesh = flver.Meshes[meshIndex];
    if (mesh.Vertices == null || mesh.Vertices.Count == 0)
    {
        continue;
    }

    var material = flver.Materials[mesh.MaterialIndex];
    var materialName = SanitizeName(material.Name ?? $"mat_{mesh.MaterialIndex}");
    if (writtenMaterials.Add(materialName))
    {
        WriteMaterial(mtl, materialName, material);
    }

    obj.AppendLine();
    obj.AppendLine($"o mesh_{meshIndex}_{materialName}");
    obj.AppendLine($"usemtl {materialName}");

    foreach (var vertex in mesh.Vertices)
    {
        obj.Append("v ");
        obj.AppendFormat(invariant, "{0:0.######} {1:0.######} {2:0.######}", vertex.Position.X * 100f, vertex.Position.Y * 100f, -vertex.Position.Z * 100f);
        obj.AppendLine();
    }

    foreach (var vertex in mesh.Vertices)
    {
        if (vertex.UVs != null && vertex.UVs.Count > 0)
        {
            obj.Append("vt ");
            obj.AppendFormat(invariant, "{0:0.######} {1:0.######}", vertex.UVs[0].X, 1f - vertex.UVs[0].Y);
            obj.AppendLine();
        }
        else
        {
            obj.AppendLine("vt 0 0");
        }
    }

    foreach (var vertex in mesh.Vertices)
    {
        obj.Append("vn ");
        obj.AppendFormat(invariant, "{0:0.######} {1:0.######} {2:0.######}", vertex.Normal.X, vertex.Normal.Y, -vertex.Normal.Z);
        obj.AppendLine();
    }

    var faceSet = mesh.FaceSets?.FirstOrDefault(fs => fs.Flags == FLVER2.FaceSet.FSFlags.None) ?? mesh.FaceSets?.FirstOrDefault();
    if (faceSet != null)
    {
        var triangles = faceSet.Triangulate(allowPrimitiveRestarts: false);
        for (var i = 0; i + 2 < triangles.Count; i += 3)
        {
            var a = triangles[i] + vertexOffset;
            var b = triangles[i + 1] + vertexOffset;
            var c = triangles[i + 2] + vertexOffset;
            obj.AppendLine($"f {a}/{a}/{a} {b}/{b}/{b} {c}/{c}/{c}");
            totalTriangles++;
        }
    }

    vertexOffset += mesh.Vertices.Count;
    totalVertices += mesh.Vertices.Count;
}

File.WriteAllText(outputObjPath, obj.ToString(), Encoding.UTF8);
File.WriteAllText(outputMtlPath, mtl.ToString(), Encoding.UTF8);

Console.WriteLine($"input={inputPath}");
Console.WriteLine($"output={outputObjPath}");
Console.WriteLine($"meshes={flver.Meshes.Count}");
Console.WriteLine($"materials={flver.Materials.Count}");
Console.WriteLine($"vertices={totalVertices}");
Console.WriteLine($"triangles={totalTriangles}");
for (var i = 0; i < flver.Materials.Count; i++)
{
    var material = flver.Materials[i];
    Console.WriteLine($"material[{i}]={material.Name} mtd={material.MTD}");
}

return 0;

static string SanitizeName(string name)
{
    var chars = name.Select(ch => char.IsLetterOrDigit(ch) || ch == '_' ? ch : '_').ToArray();
    return new string(chars);
}

static string? GetShortTextureName(string? path)
{
    if (string.IsNullOrWhiteSpace(path))
    {
        return null;
    }

    var normalized = path.Replace('\\', '/');
    var name = Path.GetFileName(normalized);
    while (!string.IsNullOrEmpty(Path.GetExtension(name)))
    {
        name = Path.GetFileNameWithoutExtension(name);
    }

    return string.IsNullOrWhiteSpace(name) ? null : name.ToLowerInvariant();
}

static void WriteMaterial(StringBuilder mtl, string materialName, FLVER2.Material material)
{
    mtl.AppendLine($"newmtl {materialName}");
    mtl.AppendLine("Ka 0.2 0.2 0.2");
    mtl.AppendLine("Kd 0.8 0.8 0.8");
    mtl.AppendLine("Ks 0.1 0.1 0.1");
    mtl.AppendLine("Ns 16");

    foreach (var texture in material.Textures)
    {
        var shortName = GetShortTextureName(texture.Path);
        if (string.IsNullOrWhiteSpace(shortName))
        {
            continue;
        }

        var type = texture.Type ?? string.Empty;
        if (type.Contains("AlbedoMap", StringComparison.OrdinalIgnoreCase))
        {
            mtl.AppendLine($"map_Kd {shortName}.tga");
        }
        else if (type.Contains("NormalMap", StringComparison.OrdinalIgnoreCase))
        {
            mtl.AppendLine($"map_Bump {shortName}.tga");
        }
    }

    mtl.AppendLine();
}

static void InspectPath(string inputPath, bool includeAllDummies)
{
    if (SoulsFile<FLVER2>.Is(inputPath))
    {
        InspectFlver(Path.GetFileName(inputPath), SoulsFile<FLVER2>.Read(inputPath), includeAllDummies);
        return;
    }

    if (SoulsFile<BND4>.Is(inputPath))
    {
        var bnd = SoulsFile<BND4>.Read(inputPath);
        Console.WriteLine($"binder={inputPath}");
        Console.WriteLine($"files={bnd.Files.Count}");
        foreach (var file in bnd.Files)
        {
            if (includeAllDummies)
            {
                Console.WriteLine($"file id={file.ID} name={file.Name} bytes={file.Bytes.Length}");
            }

            if (!file.Name.EndsWith(".flver", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            if (SoulsFile<FLVER2>.IsRead(file.Bytes, out var flver))
            {
                InspectFlver(file.Name, flver, includeAllDummies);
            }
        }
        return;
    }

    Console.Error.WriteLine($"Unsupported file: {inputPath}");
}

static void InspectFlver(string name, FLVER2 flver, bool includeAllDummies)
{
    Console.WriteLine();
    Console.WriteLine($"flver={name}");
    Console.WriteLine($"bones={flver.Bones.Count}");
    for (var i = 0; i < flver.Bones.Count; i++)
    {
        var bone = flver.Bones[i];
        if (flver.Bones.Count <= 20 || IsWeaponRelatedBoneName(bone.Name))
        {
            Console.WriteLine($"bone[{i}] name={bone.Name} parent={bone.ParentIndex} child={bone.ChildIndex} sibling={bone.NextSiblingIndex} t={bone.Translation}");
        }
    }

    Console.WriteLine($"dummies={flver.Dummies.Count}");
    foreach (var dummy in flver.Dummies.Where(dummy => includeAllDummies || flver.Dummies.Count <= 20 || IsWeaponRelatedDummy(flver, dummy)))
    {
        var parentName = GetBoneName(flver, dummy.ParentBoneIndex);
        var attachName = GetBoneName(flver, dummy.AttachBoneIndex);
        Console.WriteLine(
            $"dummy ref={dummy.ReferenceID} parent={dummy.ParentBoneIndex}:{parentName} attach={dummy.AttachBoneIndex}:{attachName} pos={dummy.Position} fwd={dummy.Forward} up={dummy.Upward} flag1={dummy.Flag1} useUp={dummy.UseUpwardVector} unk30={dummy.Unk30} unk34={dummy.Unk34}");
    }

    for (var i = 0; i < flver.Meshes.Count; i++)
    {
        var mesh = flver.Meshes[i];
        Console.WriteLine($"mesh[{i}] material={mesh.MaterialIndex}:{flver.Materials[mesh.MaterialIndex].Name} defaultBone={mesh.DefaultBoneIndex}:{GetBoneName(flver, mesh.DefaultBoneIndex)} bones=[{string.Join(",", mesh.BoneIndices.Select(index => $"{index}:{GetBoneName(flver, index)}"))}]");
    }
}

static bool IsWeaponRelatedBoneName(string? name)
{
    if (string.IsNullOrWhiteSpace(name))
    {
        return false;
    }

    return name.Contains("Weapon", StringComparison.OrdinalIgnoreCase)
        || name.Contains("Wepon", StringComparison.OrdinalIgnoreCase)
        || name.Contains("Wep", StringComparison.OrdinalIgnoreCase)
        || name.Contains("Dummy10020", StringComparison.OrdinalIgnoreCase)
        || name.Equals("R_Weapon", StringComparison.OrdinalIgnoreCase)
        || name.Equals("L_Weapon", StringComparison.OrdinalIgnoreCase);
}

static bool IsWeaponRelatedDummy(FLVER2 flver, FLVER.Dummy dummy)
{
    return dummy.ReferenceID is >= 10000 and <= 10040
        || IsWeaponRelatedBoneName(GetBoneName(flver, dummy.ParentBoneIndex))
        || IsWeaponRelatedBoneName(GetBoneName(flver, dummy.AttachBoneIndex));
}

static string GetBoneName(FLVER2 flver, int index)
{
    return index >= 0 && index < flver.Bones.Count ? flver.Bones[index].Name : "<none>";
}
