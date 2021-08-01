-- RANDOM STINGER VIDEO
-- Version 1.03
-- "Imports"
local obs = obslua
local math = require 'math'

-- Settings
local transitionName
local videoFolder

-- State
local videoStack = {}
local lastVideo = ""

-- Returns a table of video files present in a folder.
function get_videos_from_folder()
  local validFiles = {}

  if videoFolder == "" then
    return validFiles
  end

  -- Attempt to open directory
  local dir = obs.os_opendir(videoFolder)

  if dir then
    local entry

    -- Iterate through entries
    repeat
      entry = obs.os_readdir(dir)
      if entry and not entry.directory then
        local fullPath = videoFolder .. "/" .. entry.d_name
        local fileExt = obs.os_get_path_extension(entry.d_name)

        -- if it is a video file, add it to the table
        if fileExt == ".mp4" or fileExt == ".ts" or fileExt == ".mov" or fileExt == ".wmv" or fileExt == ".flv" or
          fileExt == ".mkv" or fileExt == ".avi" or fileExt == ".gif" or fileExt == ".webm" then
          table.insert(validFiles, fullPath)
        end
      end
    until not entry
    obs.os_closedir(dir)
  end

  return validFiles
end

-- Shuffles elements of a table
function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

-- Returns the last element in the videoStack
-- table, and removes it from the list
function pop_video_from_stack()
  -- if the videoStack is empty, generate a new stack
  if #videoStack == 0 then
    videoStack = get_videos_from_folder()

    if #videoStack == 0 then
      return ""
    end

    -- Small looop to prevent the same video from being presented twice
    -- when a new stack is generated
    repeat
      shuffle(videoStack)
    until (#videoStack < 2 or videoStack[#videoStack] ~= lastVideo)
  end

  if #videoStack == 0 then
    return ""
  end

  lastVideo = videoStack[#videoStack]
  table.remove(videoStack)
  return lastVideo
end

-- Set a new video on the selected transition
function set_random_video_on_transition()
  if transitionName == nil or transitionName == "" then
    return
  end

  local randomFile = pop_video_from_stack()
  if randomFile == "" then
    return
  end

  obs.script_log(obs.LOG_INFO, "Selected video: " .. randomFile)

  -- Unfortunately, obs_get_source_by_name doesn't work
  -- on transition source; will need to iterate through
  -- sources returned by obs_frontend_get_transitions()
  local transitions = obs.obs_frontend_get_transitions()
  for _, source in ipairs(transitions) do
    source_id = obs.obs_source_get_id(source)

    -- If the source is a stinger_transition
    if source_id == "obs_stinger_transition" then
      local name = obs.obs_source_get_name(source)

      -- and matches the expected name
      if name == transitionName then
        -- set its "path" property to the new video
        local settings = obs.obs_source_get_settings(source)
        obs.obs_data_set_string(settings, "path", randomFile)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
      end
    end
  end

  -- release references to sources to prevent memory leaks
  obs.source_list_release(transitions)
end

-- Built-in: raised on OBS events
function on_event(event)
  -- When the scene has changed, set a new video to the transition source
  if event == obs.OBS_FRONTEND_EVENT_SCENE_CHANGED then
    set_random_video_on_transition()
  end
end

-- Built-in: Called when the script’s settings (if any) have been changed by the user.
function script_update(settings)
  -- Read settings
  transitionName = obs.obs_data_get_string(settings, "transition")
  videoFolder = obs.obs_data_get_string(settings, "videoFolder")

  -- Reset video stack and seed random number generator
  videoStack = {}
  math.randomseed(os.time())

  -- Set a new video on the transition source
  set_random_video_on_transition()
end

-- Built-in: Called to define user properties associated with the script.
function script_properties()
  local props = obs.obs_properties_create()

  local p = obs.obs_properties_add_list(props, "transition", "Transition", obs.OBS_COMBO_TYPE_LIST,
    obs.OBS_COMBO_FORMAT_STRING)
  local transitions = obs.obs_frontend_get_transitions()

  if transitions ~= nil then
    for _, source in ipairs(transitions) do
      source_id = obs.obs_source_get_id(source)
      if source_id == "obs_stinger_transition" then
        local name = obs.obs_source_get_name(source)
        obs.obs_property_list_add_string(p, name, name)
      end
    end
  end
  obs.source_list_release(transitions)

  obs.obs_properties_add_path(props, "videoFolder", "Video folder", obs.OBS_PATH_DIRECTORY, "*", nil)

  return props
end

-- Built-in: Called on script startup with specific settings associated with the script.
function script_load(settings)
  obs.obs_frontend_add_event_callback(on_event)
end

-- Built-in: Returns the script description.
function script_description()
  return
    "Randomly assigns a video to a stinger transition on scene change.\nAuthors: FineWolf <me@finewolf.com>, extraxterrestrial\nVersion: 1.03"
end
