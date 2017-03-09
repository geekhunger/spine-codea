--------------------------------------------------------------------------
-- Spine-Codea
-- Supports spine-lua runtime 3.5.03
--
-- NOTE: Download the runtime from https://github.com/EsotericSoftware/spine-runtimes/tree/master/spine-lua
-- Drop that folder into your Dropbox inside Codea's root folder
-- Make sure "Lfs" class is included in your project
--
-- USE: actor_name = spine.Actor(lfs.DROPBOX.."/sub-dir", "skeleton.json", "skeleton.atlas")
--------------------------------------------------------------------------

local QUAD_TRIANGLES = {1, 2, 3, 3, 4, 1}

spine = {}

spine.Actor = class()
spine.utils = require "spine-lua.utils"
spine.SkeletonJson = require "spine-lua.SkeletonJson"
spine.SkeletonData = require "spine-lua.SkeletonData"
spine.BoneData = require "spine-lua.BoneData"
spine.SlotData = require "spine-lua.SlotData"
spine.IkConstraintData = require "spine-lua.IkConstraintData"
spine.Skin = require "spine-lua.Skin"
spine.Attachment = require "spine-lua.attachments.Attachment"
spine.BoundingBoxAttachment = require "spine-lua.attachments.BoundingBoxAttachment"
spine.RegionAttachment = require "spine-lua.attachments.RegionAttachment"
spine.MeshAttachment = require "spine-lua.attachments.MeshAttachment"
spine.VertexAttachment = require "spine-lua.attachments.VertexAttachment"
spine.PathAttachment = require "spine-lua.attachments.PathAttachment"
spine.Skeleton = require "spine-lua.Skeleton"
spine.Bone = require "spine-lua.Bone"
spine.Slot = require "spine-lua.Slot"
spine.IkConstraint = require "spine-lua.IkConstraint"
spine.AttachmentType = require "spine-lua.attachments.AttachmentType"
spine.AttachmentLoader = require "spine-lua.AttachmentLoader"
spine.Animation = require "spine-lua.Animation"
spine.AnimationStateData = require "spine-lua.AnimationStateData"
spine.AnimationState = require "spine-lua.AnimationState"
spine.EventData = require "spine-lua.EventData"
spine.Event = require "spine-lua.Event"
spine.SkeletonBounds = require "spine-lua.SkeletonBounds"
spine.BlendMode = require "spine-lua.BlendMode"
spine.TextureAtlas = require "spine-lua.TextureAtlas"
spine.TextureRegion = require "spine-lua.TextureRegion"
spine.TextureAtlasRegion = require "spine-lua.TextureAtlasRegion"
spine.AtlasAttachmentLoader = require "spine-lua.AtlasAttachmentLoader"
spine.Color = require "spine-lua.Color"

spine.utils.readJSON = json.decode

function spine.utils.readFile(file_name, base_path)
    local src = lfs.read(base_path and base_path.."/"..file_name or file_name)
    return src
end

function spine.utils.readImage(file_name, base_path)
    return image(spine.utils.readFile(file_name, base_path))
end

function spine.utils.print(t, indent)
    if not indent then indent = "" end
    local names = {}
    for n, g in pairs(t) do
        table.insert(names, n)
    end
    table.sort(names)
    for i, n in pairs(names) do
        local v = t[n]
        if type(v) == "table" then
            if v == t then -- prevent endless loop on self reference
                print(indent..tostring(n)..": <-")
            else
                print(indent..tostring(n)..":")
                spine.utils.print(v, indent.."   ")
            end
        elseif type(v) == "function" then
            print(indent..tostring(n).."()")
        else
            print(indent..tostring(n)..": "..tostring(v))
        end
    end
end

function spine.Actor:init(base_path, json_file, atlas_file, default_skin, scale_factor)
    base_path = base_path or lfs.DROPBOX
    local image_loader = function(file) return spine.utils.readImage(file, base_path) end
    local atlas_data = spine.TextureAtlas.new(spine.utils.readFile(atlas_file, base_path), image_loader)
    json_data = spine.SkeletonJson.new(spine.AtlasAttachmentLoader.new(atlas_data))
    json_data.scale = scale_factor or 1
    local skeleton_data = json_data:readSkeletonDataFile(json_file, base_path)
    local animation_data = spine.AnimationStateData.new(skeleton_data)
    
    self.skeleton = spine.Skeleton.new(skeleton_data)
    self.skeleton:setSkin(default_skin or "default")
    self.skeleton:setToSetupPose()
    self.animation = spine.AnimationState.new(animation_data)
    self.mesh = mesh()
    self.mesh:resize(1500) -- NOTE: if Codea crashes try increase the buffer size!
    self.mesh.vertex_buffer = self.mesh:buffer("position")
    self.mesh.texture_buffer = self.mesh:buffer("texCoord")
    self.mesh.color_buffer = self.mesh:buffer("color")
end

function spine.Actor:setPosition(new_x, new_y)
    self.skeleton.x = new_x
    self.skeleton.y = new_y
end

function spine.Actor:setScale(new_scale_x, new_scale_y)
    self.skeleton.scaleX = new_scale_x
    self.skeleton.scaleY = new_scale_y or new_scale_x
end

function spine.Actor:setSkin(new_skin_name)
    self.skeleton.skin = nil -- reset skin!
    self.skeleton:setSkin(new_skin_name)
end

function spine.Actor:setAnimation(new_animation_name, loop, crossfade_time)
    local track_entry = self.animation:setAnimationByName(0, new_animation_name, loop)
    track_entry.mixDuration = crossfade_time or .1
end

function spine.Actor:queueAnimation(animation_name, loop, delay)
    self.animation:addAnimationByName(0, animation_name, loop, delay or 0)
end

function spine.Actor:draw()
    pushMatrix()
    scale(self.skeleton.scaleX or 1, self.skeleton.scaleY or 1)
    
    self.animation:update(DeltaTime)
    self.animation:apply(self.skeleton)
    self.skeleton:updateWorldTransform()
    
    for i, slot in ipairs(self.skeleton.drawOrder) do
        local attachment = slot.attachment
        
        if attachment then
            local texture, vertices, triangles
            
            if attachment.type == spine.AttachmentType.region then
                texture = attachment.region.renderObject.texture
                vertices = attachment:updateWorldVertices(slot, true)
                triangles = QUAD_TRIANGLES
            elseif attachment.type == spine.AttachmentType.mesh then
                texture = attachment.region.renderObject.texture
                vertices = attachment:updateWorldVertices(slot, true)
                triangles = attachment.triangles
            end
            
            if texture and vertices and triangles then
                pushStyle()
                
                local faces = {}
                local uvs = {}
                local colors = {}
                local blend_mode = slot.data.blendMode
                
                if blend_mode == spine.BlendMode.additive then blendMode(ADDITIVE)
                elseif blend_mode == spine.BlendMode.multiply then blendMode(MULTIPLY)
                elseif blend_mode == spine.BlendMode.screen then blendMode(ONE, ONE_MINUS_SRC_COLOR)
                else blendMode(NORMAL) end -- blend_mode == spine.BlendMode.normal and undefined
                
                -- triangulate and supply to GPU
                for j, id in ipairs(triangles) do -- listed in cw order
                    local pos = id * 8 - 8
                    local vert = vec2(vertices[pos + 1], vertices[pos + 2])
                    local uv = vec2(vertices[pos + 3], 1 - vertices[pos + 4]) -- flip y
                    local r = vertices[pos + 5] * 255
                    local g = vertices[pos + 6] * 255
                    local b = vertices[pos + 7] * 255
                    local a = vertices[pos + 8] * 255
                    table.insert(faces, vert)
                    table.insert(uvs, uv)
                    table.insert(colors, color(r, g, b, a))
                end
                
                self.mesh:clear()
                self.mesh.texture = texture
                self.mesh.vertex_buffer:set(faces)
                self.mesh.texture_buffer:set(uvs)
                self.mesh.color_buffer:set(colors)
                self.mesh:draw()
                
                popStyle()
            end
        end
    end
    
    popMatrix()
end
