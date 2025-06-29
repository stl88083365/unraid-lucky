<?PHP

require_once("/usr/local/emhttp/plugins/lucky/scripts/helpers.php");

function makeCron($frequency,$custom) {
  switch ($frequency) {
    case "Custom":
      $cronSetting = $custom;
      break;
    case "disabled":
      $cronSetting = false;
      break;
    default:
      $cronSetting = "Invalid guardian setting of $frequency";
      break;
  }
  return $cronSetting;
}


switch ($_POST['action']) {

case 'stopProgram':
    shell_exec("pkill lucky");
    @unlink("/boot/config/plugins/lucky/plugin_update.cron");
    $updateArray = readJsonFile("/boot/config/plugins/lucky/AutoRunSettings.json");
    $updateArray['cron']['pluginCronFrequency'] = 'disabled';
    writeJsonFile("/boot/config/plugins/lucky/AutoRunSettings.json",$updateArray);
    exec("/usr/local/sbin/update_cron");
    break;

case 'autoUpdatePlugins':
  $pluginList            = getPostArray("pluginList","");
  $pluginCron            = getPostArray("pluginCron");
  foreach ($pluginCron as $setting) {
    $updateArray['cron'][$setting[0]] = trim($setting[1]);
  }

  $frequency  = $updateArray['cron']['pluginCronFrequency'];
  $custom     = $updateArray['cron']['pluginCronCustom'];
  
  $pluginCron = "# Spawning the settings for the lucky process daemon\n";
  $generatedCron = makeCron($frequency,$custom);
  $pluginCron .= "$generatedCron /usr/local/emhttp/plugins/lucky/scripts/luckypid.sh >/dev/null 2>&1\n";
    
  if ( $generatedCron ) {
    file_put_contents("/boot/config/plugins/lucky/plugin_update.cron",$pluginCron);
  } else {
    @unlink("/boot/config/plugins/lucky/plugin_update.cron");
  }
  writeJsonFile("/boot/config/plugins/lucky/AutoRunSettings.json",$updateArray);
  exec("/usr/local/sbin/update_cron");
  break;

case 'saveSuffix':
    try {
        $suffix = $_POST['suffix'];
        $suffix_dir = "/boot/config/plugins/lucky";
        $suffix_file = "$suffix_dir/suffix.cfg";
        
        // 确保目录存在
        if (!is_dir($suffix_dir)) {
            if (!mkdir($suffix_dir, 0755, true)) {
                error_log("Failed to create directory: $suffix_dir");
                echo json_encode(['success' => false, 'error' => 'Failed to create directory']);
                return;
            }
        }
        
        // 保存后缀到文件
        if (file_put_contents($suffix_file, $suffix) === false) {
            error_log("Failed to write to file: $suffix_file");
            echo json_encode(['success' => false, 'error' => 'Failed to write file']);
            return;
        }
        
        echo json_encode(['success' => true]);
    } catch (Exception $e) {
        error_log("Error saving suffix: " . $e->getMessage());
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    break;
}
?>
