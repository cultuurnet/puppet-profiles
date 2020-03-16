class profiles::aptly {

	class { 'aptly':                                                                    
		s3_publish_endpoints =>                                                           
		{ 
			'apt.publiq.be' =>                                                           
			{ 
				'region' => 'eu-west-1',                                                                                                                                                                      
				'bucket' => 'apt.publiq.be' 
				'awsAccessKeyID' => 'AKIAIVJBGNGHTNGMYNEA'
				'awsSecretAccessKey' => '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'
			}                                                                              
		}                                                                                
	}
}
